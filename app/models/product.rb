class Product < ApplicationRecord
  belongs_to :group
  has_many :orders
  has_many :sales_numbers, as: :numberable
  has_many :customer_products
  has_many :customers, through: :customer_products
  has_many :user_products
  has_many :users, through: :user_products

  def get_age
    (Date.today - self.orders.minimum(:invoice_date)).to_i
  end

  def update_sales
    end_date = self.orders.maximum(:invoice_date)
    self.update(

      sales_year: self.orders.where('invoice_date <= ? AND invoice_date >= ?', end_date, end_date.last_year).sum(:total),
      prev_sales_year: self.orders.where('invoice_date <= ? AND invoice_date >= ?', end_date.last_year, end_date.last_year.last_year).sum(:total),
      sales_ytd: self.orders.where('invoice_date <= ? AND invoice_date >= ?', end_date, end_date.beginning_of_year).sum(:total),
      prev_sales_ytd: self.orders.where('invoice_date <= ? AND invoice_date >= ?', end_date.last_year, end_date.last_year.beginning_of_year).sum(:total),

      quantity: self.orders.where('invoice_date <= ? AND invoice_date >= ?', end_date, end_date.last_year).sum(:quantity),
      prev_quantity: self.orders.where('invoice_date <= ? AND invoice_date >= ?', end_date.last_year, end_date.last_year.last_year).sum(:quantity),
      quantity_ytd: self.orders.where('invoice_date <= ? AND invoice_date >= ?', end_date, end_date.beginning_of_year).sum(:quantity),
      prev_quantity_ytd: self.orders.where('invoice_date <= ? AND invoice_date >= ?', end_date.last_year, end_date.last_year.beginning_of_year).sum(:quantity),

      age: self.get_age
    )
    self.orders.where(promo: false).first ? @price = self.orders.where(promo: false).first.price : @price = nil
    self.orders.where(promo: true).first ? @promo_price = self.orders.where(promo: true).first.price : @promo_price = nil
    self.update(price: @price, promo_price: @promo_price)
    self.update(
      growth: self.sales_year - self.prev_sales_year,
      growth_ytd: self.sales_ytd - self.prev_sales_ytd,
      quantity_growth: self.quantity - self.prev_quantity,
      quantity_growth_ytd: self.quantity_ytd - self.prev_quantity_ytd
    )
  end

  def self.update_sales
    products = Product.all.includes(:orders)
    products.each do |product|
      product.update_sales
    end
  end

  def write_sales_number(month, year)
    sales = self.orders.where("invoice_date >= ? AND invoice_date <= ?", Date.new(year, month), Date.new(year, month).end_of_month).sum(:total)
    quantity = self.orders.where("invoice_date >= ? AND invoice_date <= ?", Date.new(year, month), Date.new(year, month).end_of_month).sum(:quantity)
    self.sales_numbers.create(month: month, year: year, sales: sales, quantity: quantity)
  end

  def self.write_sales_numbers
    @products = Product.all.includes(:orders)
    @products.each do |product|
      start_year = product.orders.minimum(:invoice_date).year
      end_year = product.orders.maximum(:invoice_date).year
      (start_year..end_year).each do |year|
        12.times do |t|
          month = t + 1
          unless product.sales_numbers.where(month: month, year: year).length > 0
            sales = product.orders.where("invoice_date >= ? AND invoice_date <= ?", Date.new(year, month), Date.new(year, month).end_of_month).sum(:total)
            quantity = product.orders.where("invoice_date >= ? AND invoice_date <= ?", Date.new(year, month), Date.new(year, month).end_of_month).sum(:quantity)
            product.sales_numbers.create(month: month, year: year, sales: sales, quantity: quantity)
          end
        end
      end
    end
  end

  def get_sales_numbers(date = Date.today)
    numbers = []
    12.times do |time|
      if date.month - time > 0
        month = date.month - time
        year = date.year
      else
        month = date.month - time + 12
        year = date.year - 1
      end
      numbers << [
        Date.new(year, month).strftime("%b %Y"),
        self.sales_numbers.where(month: month, year: year).pluck(:sales).first,
        self.sales_numbers.where(month: month, year: year - 1).pluck(:sales).first
      ]
    end
    numbers.reverse
  end

  def self.ordered_sales_numbers(user, order_by = "sales", reverse = false, customer_id = nil, category = nil)
    end_date = Order.maximum(:invoice_date)
    orders = user.orders.joins(:product)
    if category
      orders = orders.where("products.category = ?", category)
    end

    unless customer_id
      sales_year = orders
      .within_year(end_date)
      .group('products.id, number')
      .having("sum(total) > 5000")
      .select('products.id, number, sum(total) as real_sales_year, sum(orders.quantity) as quantity')

      prev_year = orders
      .within_year(end_date - 1.year)
      .group('products.id')
      .having("sum(total) > 5000")
      .select('products.id, number, sum(total) as real_prev_sales_year, sum(orders.quantity) as prev_quantity')
    else
      sales_year = orders
      .where("customer_id = ?", customer_id)
      .within_year(end_date)
      .group('products.id, number')
      .having("sum(total) > 5000")
      .select('products.id, number, sum(total) as real_sales_year, sum(orders.quantity) as quantity')

      prev_year = orders
      .where("customer_id = ?", customer_id)
      .within_year(end_date  - 1.year)
      .group('products.id')
      .having("sum(total) > 5000")
      .select('products.id, number, sum(total) as real_prev_sales_year, sum(orders.quantity) as prev_quantity')
    end

    sales_year = sales_year
    .map do |e|
      Product.new(
        id: e.id,
        number: e.number,
        sales_year: e.real_sales_year,
        growth: e.real_sales_year,
        quantity: e.quantity,
        quantity_growth: e.quantity,
      )
    end



    prev_year.group('products.id')
    .each do |e|
      product = sales_year.select{ |s| e if s.id == e.id}.first
      if product
        product.prev_sales_year = e["real_prev_sales_year"]
        product.growth = product.sales_year - e["real_prev_sales_year"]
        product.prev_quantity = e["prev_quantity"]
        product.quantity_growth = product.quantity - e["prev_quantity"]
      else
        sales_year.push(
          Product.new(
            id: e.id,
            sales_year: 0,
            number: e["number"],
            growth: 0-e["real_prev_sales_year"],
            prev_sales_year: e["real_prev_sales_year"],
            quantity_growth: 0-e["prev_quantity"],
            prev_quantity: e["prev_quantity"],
          )
        )
      end
    end

    sales_arr = sales_year


    if order_by == "sales"
      sales_arr.sort_by! {|e| e.sales_year}
    elsif order_by == "growth"
      sales_arr.sort_by! {|e| e.growth}
    elsif order_by == "number"
      sales_arr.sort_by! {|e| e.number}.reverse!
    end
    sales_arr.reverse! if reverse
    return sales_arr
  end

  def get_sales_year(user_id, quantity = false, end_date = Order.maximum(:invoice_date))
    orders = self.orders.where(user_id: user_id).within_year(end_date)
    if quantity
      orders.sum(:quantity)
    else
      orders.sum(:total)
    end
  end

  def get_growth(user_id, quantity = false, end_date = Order.maximum(:invoice_date))
    self.get_sales_year(user_id, quantity, end_date) - self.get_sales_year(user_id, quantity, end_date - 1.year)
  end
end
