require 'csv'
class Upload
  def self.csv(csv, user_id, final = false)
    @user = User.find(user_id)
    @categories = {}
    CSV.read('pricebook.csv', headers: true).each do |row|
      @categories[row["Model"]] = find_category(row["Catalog_Page"])
    end

    CSV.read(csv, headers: true).each do |row|
      @customer = @user.customers.find_by_name_id(row["Customer ID"])
      unless @customer
        @name = row["Customer Name"].titlecase
        @customer = Customer.create(name: @name, user_id: user_id, name_id: row["Customer ID"], state: row["State"])
      end
      @product = Product.find_by_number(row["Model"])
      unless @product
        @group = Group.where(number: row["Model"], category: @categories[row["Model"]]).first
        unless @group
          @group = Group.where(number: group_number(row["Model"]), category: @categories[row["Model"]]).first
          unless @group
            @group = Group.create(number: group_number(row["Model"]), category: @categories[row["Model"]])
          end
        end
        @category = @group.category
        @product = @group.products.create(number: row["Model"], category: @category)
      else
        @group = @product.group
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
      @order = Order.create(customer_id: @customer.id, invoice_id: row["Invoice"], invoice_date: convert_date(row["Invoice Date"]), quantity: row["Order Qty"], promo: promo(row["Price Name"]), user_id: user_id, product_id: @product.id, total: row["Order Price"].delete(",").to_f)
      if @order.total != 0 && @order.quantity != 0
        @order.update(price: (@order.total / @order.quantity))
      end
    end
    update_sales(@user, final)
  end

  def self.update_sales(user, final)
    user.update_sales
    user.update_sales_numbers
    if final
      Product.update_sales
      Customer.update_sales
      Group.update_sales
      UserProduct.update_sales
      UserGroup.update_sales
      UserProduct.write_sales_numbers
      UserGroup.write_sales_numbers
      CustomerProduct.update_sales
      CustomerGroup.update_sales
      SalesNumber.write_sales_numbers
    end
    # Customer.write_recommendations
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
    elsif number =~ /\dK-/
      return number.split('-').first.delete('K')
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

  def self.find_category(page)
    unless page
      return nil
    end
    book = page.split("-").first
    if book.include?("B")
      return "bedroom"
    elsif book.include?("S")
      return "seating"
    elsif book.include?("D")
      return "dining"
    elsif book.include?("T")
      return "occasional"
    elsif book.include?("Y")
      return "youth"
    elsif book.include?("H")
      return "home"
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
