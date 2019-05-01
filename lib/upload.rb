require 'csv'
class Upload
  def self.csv(csvs, single = false)
    #create category book
    @categories = {}
    CSV.read('pricebook.csv', headers: true).each do |row|
      @categories[row["Model"]] = find_category(row["Catalog_Page"])
    end

    # initialize empty arrays to keep track of what was edited
    # @products = []
    # @customers = []
    # @groups = []
    # @dates = []
    # @users = []
    # @user_groups = []
    # @user_products = []

    csvs.each do |hash|
      @user = User.find(hash[:user_id])
      # Loop through csv with sales info
      CSV.read(hash[:csv], headers: true, :encoding => 'ISO-8859-1').each do |row|
        # find customer
        @customer = @user.customers.find_by_name_id(row["Customer ID"])

        # if no customer exists create a new customer
        unless @customer
          @name = row["Customer Name"].titlecase
          @customer = Customer.create(name: @name, user_id: hash[:user_id], name_id: row["Customer ID"], state: row["State"])
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
          @product = @group.products.create(number: row["Model"], category: @categories[row["Model"]])
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
        @order = Order.new(customer_id: @customer.id, invoice_id: row["Invoice"], invoice_date: convert_date(row["Invoice Date"]), quantity: row["Order Qty"], promo: promo(row["Price Name"]), user_id: hash[:user_id], product_id: @product.id, total: row["Order Price"].delete(",").to_f)
        if @order.total != 0 && @order.quantity != 0
          @order.price = (@order.total / @order.quantity)
          @order.save!
        end

        # @user_group = @user.user_groups.find_by(group_id: @group.id)
        # @user_product = @user.user_products.find_by(product_id: @product.id)
        #
        # @date = {month: @order.invoice_date.month, year: @order.invoice_date.year}


        # add products, customers, and groups to arrays
        # if single
        #   @products << @product unless @products.include?(@product)
        #   @customers << @customer unless @customers.include?(@customer)
        #   @groups << @group unless @groups.include?(@group)
        #   @dates << @date unless @dates.include?(@date)
        #   @users << @user unless @users.include?(@user)
        #   @user_products << @user_product unless @user_products.include?(@user_product)
        #   @user_groups << @user_group unless @user_groups.include?(@user_group)
        # end
      end
      # @user.update_sales_numbers

    end
    # update sales info for the products, customers and groups

    # if single
    #   Upload.update_sale_array([@customers, @products, @groups, @users, @user_products, @user_groups])
    # end
  end

  def self.upload_from_json(user_id, numbers)
    @categories = {}
    CSV.read('pricebook.csv', headers: true).each do |row|
      @categories[row["Model"]] = find_category(row["Catalog_Page"])
    end

    @user = User.find(user_id)
    numbers.each_with_index do |row, i|
      puts i
      @customer = @user.customers.find_by_name_id(row["customer"])
      unless @customer
        @name = row["customerName"].titlecase
        @customer = Customer.create(name: @name, user_id: user_id, name_id: row["customer"], state: row["state"])
      end

      @product = Product.find_by_number(row["model"])
      unless @product
        @group = Group.find_by(number: row["model"], category: @categories[row["model"]])
        unless @group
          @group = Group.find_by(number: group_number(row["model"]), category: @categories[row["model"]])
          unless @group
            @group = Group.create(number: group_number(row["model"]), category: @categories[row["model"]])
          end
        end
        @category = @group.category
        @product = @group.products.create(number: row["model"], category: @categories[row["model"]])
      else
        @group = @product.group
      end

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

      @order = Order.create(customer_id: @customer.id, invoice_id: row["invoice"], invoice_date: row["invoiceDate"].to_date, quantity: row["totalQty"], promo: promo(row["priceName"]), user_id: user_id, product_id: @product.id, total: row["totalPrice"], price: row["unitPrice"])
    end
  end

  def self.update_sales
    Product.update_sales
    Group.update_sales
    User.all.each {|e| e.update_sales}
    Customer.all.each {|e| e.update_sales}
    # Customer.write_sales_numbers
    # Product.write_sales_numbers
    # Group.write_sales_numbers
    # UserProduct.write_sales_numbers
    # UserGroup.write_sales_numbers
    # SalesNumber.write_sales_numbers
    # Customer.write_recommendations
  end

  def self.update_sale_array(arrs)
    arrs.each do |arr|
      arr.each do |e|
        e.update_sales
        @dates.each do |date|
          e.write_sales_number(date[:month], date[:year])
        end
      end
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

  def self.i_forgot(user_id)
    user = User.find(user_id)
    user.orders.each do |order|
      product = order.product
      group = product.group
      customer = order.customer
      unless user.products.include?(product)
        user.products << product
      end

      unless user.groups.include?(group)
        user.groups << group
      end

      unless customer.products.include?(product)
        order.customer.products << order.product
      end

      unless customer.groups.include?(group)
        customer.groups << group
      end
    end
  end
end
