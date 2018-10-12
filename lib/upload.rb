require 'csv'
class Upload
  def self.csv(csv, user_id, final = false)
    # find user and create category book
    @user = User.find(user_id)
    @categories = {}
    CSV.read('pricebook.csv', headers: true).each do |row|
      @categories[row["Model"]] = find_category(row["Catalog_Page"])
    end

    # initialize empty arrays to keep track of what was edited
    @products = []
    @customers = []
    @groups = []


    # Loop through csv with sales info
    CSV.read(csv, headers: true).each do |row|
      # find customer
      @customer = @user.customers.find_by_name_id(row["Customer ID"])

      # if no customer exists create a new customer
      unless @customer
        @name = row["Customer Name"].titlecase
        @customer = Customer.create(name: @name, user_id: user_id, name_id: row["Customer ID"], state: row["State"])
      end

      # find product
      @product = Product.find_by_number(row["Model"])

      # if no product exists:
        # Find the group the product belongs to
        # create a new product within that group
      unless @product
        @group = Group.find_by(number: row["Model"], category: @categories[row["Model"]])
        unless @group
          @group = Group.find_by(number: group_number(row["Model"]), category: @categories[row["Model"]])
          unless @group
            @group = Group.create(number: group_number(row["Model"]), category: @categories[row["Model"]])
          end
        end
        @category = @group.category
        @product = @group.products.create(number: row["Model"], category: @category)
      else
        @group = @product.group
      end

      # if customer doesn't have product in customers_proudcts add it
      unless @customer.products.include?(@product)
        @customer.products << @product
      end

      # if user doesn't have product in products_users add it
      unless @user.products.include?(@product)
        @user.products << @product
      end

      # if customer doesn't have group in customers_groups add it
      unless @customer.groups.include?(@group)
        @customer.groups << @group
      end

      # if user doesn't have group in groups_users add it
      unless @user.groups.include?(@group)
        @user.groups << @group
      end

      # create order
      @order = Order.create(customer_id: @customer.id, invoice_id: row["Invoice"], invoice_date: convert_date(row["Invoice Date"]), quantity: row["Order Qty"], promo: promo(row["Price Name"]), user_id: user_id, product_id: @product.id, total: row["Order Price"].delete(",").to_f)
      if @order.total != 0 && @order.quantity != 0
        @order.update(price: (@order.total / @order.quantity))
      end


      # add products, customers, and groups to arrays
      @products << @product unless @products.include?(@product)
      @customers << @customer unless @customers.include?(@customer)
      @groups << @group unless @groups.include?(@group)
    end

    # update sales info for the products, customers and groups
    @date = Order.maximum(:invoice_date)
    [@customers, @products, @groups].each do |arr|
      arr.each do |e|
        e.update_sales
        e.write_sales_number(@date.month, @date.year)
      end
    end
    @user.update_sales
    @user.update_sales_numbers
  end

  def self.update_sales(user, final)
    if final
      UserProduct.write_sales_numbers
      UserGroup.write_sales_numbers
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
