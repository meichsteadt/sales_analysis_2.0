require 'csv'
class Upload
  def self.csv(csv, user_id)
    @price_book = {}
    @user = User.find(user_id)
    CSV.read('2018price_book.csv', headers: true).each do |row|
      @price_book[row['Item#'].delete("*")] = get_category(row['Page'])
    end

    CSV.read(csv, headers: true).each do |row|
      @customer = @user.customers.find_by_name_id(row["Customer ID"])
      unless @customer
        @customer = Customer.create(name: row["Customer Name"].titlecase, user_id: user_id, name_id: row["Customer ID"], state: row["State"])
      end
      @product = @user.products.find_by_number(row["Model"])
      unless @product
        @group = Group.find_by_number(row["Model"])
        unless @group
          @group = Group.find_by_number(group_number(row["Model"]))
          unless @group
            @group = Group.create(number: group_number(row["Model"]), category: find_category(row["Model"], @price_book))
          end
        end
        @category = @group.category
        @product = @group.products.create(number: row["Model"], category: @category)
      end
      unless @customer.products.include?(@product)
        @customer.products << @product
      end
      unless @user.products.include?(@product)
        @user.products << @product
      end
      unless @customer.groups.include?(@group)
        @customer.groups << @group
      end
      unless @user.groups.include?(@group)
        @user.groups << @group
      end
      @order = Order.create(customer_id: @customer.id, invoice_id: row["Invoice"], invoice_date: convert_date(row["Invoice Date"]), quantity: row["Order Qty"], promo: promo(row["Price Name"]), user_id: user_id, product_id: @product.id, price: row["  Order Price"])
      @order.update(total: (@order.price * @order.quantity))
    end
  end

  def self.get_category(page)
    unless page
      return nil
    end
    @letter = page.split("-").first
    if @letter == "D"
      return 'dining'
    elsif @letter == "S"
      return 'seating'
    elsif @letter == "B"
      return 'bedroom'
    elsif @letter == "Y"
      return 'youth'
    elsif @letter == "H"
      return 'home'
    elsif @letter == "T"
      return 'occasional'
    end
  end

  def self.group_number(number)
    if number =~ /-1.K/ || number =~ /-3.K/
      return number.split('-').first[0..-2]
    elsif number =~ /TF.-1/ || number =~ /TF-1/ || number =~ /TF.-2/ || number =~ /TF-2/ || number =~ /TF.-3/ || number =~ /TF-3/
      return number.split('-').first.delete('TF')
    elsif number =~ /F.-1/ || number =~ /F-1/ || number =~ /F.-2/ || number =~ /F-2/ || number =~ /F.-3/ || number =~ /F-3/
      return number.split('-').first.delete('F')
    elsif (number =~ /T.-1/ || number =~ /T-1/ || number =~ /T.-2/ || number =~ /T-2/ || number =~ /T.-3/ || number =~ /T-3/) && !(number =~ /TP.-/ || number =~ /TP-/)
      return number.split('-').first.delete('T')
    elsif number.split("-").first[-1] == "S" && !(number =~ /F.S/)
      return number[0..-2]
    else
      return number.split('-').first
    end
  end

  def self.find_category(number, price_book, try = 0)
    category = price_book[number]
    if !category && try <= 4
      try += 1
      if try == 1
        find_category((number.split('-').first + "-" + number.split('-')[1].gsub("3", "1")), price_book, try)
      elsif try == 2
        find_category((number.split('-').first + "-" + number.split('-')[1].gsub("2", "1")), price_book, try)
      elsif try == 3
        find_category((number.split('-').first + "-" + number.split('-')[1].gsub("1", "1CK")), price_book, try)
      else
        find_category(number.split('-').first + "-3", price_book, try)
      end
    elsif try > 4
      category = ''
    else
      return category
    end
  end

  def self.convert_date(string)
    month = string.split('/')[0].to_i
    day = string.split('/')[1].to_i
    year = string.split('/')[2].to_i
    Date.new(year, month, day)
  end

  def self.promo(price_name)
    price_name === "Promotional Price" ? true : false
  end
end
