class Customer < ApplicationRecord
  belongs_to :user
  has_many :orders
  has_and_belongs_to_many :products
  has_and_belongs_to_many :groups

  def sales_year(year = Date.today.year)
    self.orders.where("invoice_date >= ? AND invoice_date <= ?", Date.new(year), Date.new(year).end_of_year).map {|e| (e.price * e.quantity)}.sum
  end

  def sales_month(year = Date.today.year, month = Date.today.month)
    self.orders.where("invoice_date >= ? AND invoice_date <= ?", Date.new(year, month), Date.new(year, month).end_of_month).map {|e| (e.price * e.quantity)}.sum
  end

  def sales_ytd(date = Date.today)
    self.orders.where("invoice_date >= ? AND invoice_date <= ?", date.last_year, date).map {|e| (e.price * e.quantity)}.sum
  end

  def sales_where(start_month, start_year, end_month, end_year)
    start_date = Date.new(start_year, start_month)
    end_date = Date.new(end_year, end_month).end_of_month
    self.orders.where("invoice_date >= ? AND invoice_date <= ?", start_date, end_date).map {|e| (e.price * e.quantity)}.sum
  end

  def product_mix(year = Date.today.year)
    categories = ["dining", "bedroom", "seating", "youth", "occasional", "home"]
    categories_hash = {}
    categories.each do |category|
      if self.products.where(category: category).any?
        categories_hash[category] = (self.products.where(category: category).map {|e| e.sales_year(self.user_id, self.id, year)}.sum / self.sales_year(year))
      else
        categories_hash[category] = 0
      end
    end
    categories_hash
  end

  def category_sales(category, date = Date.today)
    self.products.where(category: category).map {|e| e.sales_ytd(self.user_id, self.id, date)}.sum
  end

  def growth(date = Date.today)
    self.sales_ytd(date) - self.sales_ytd(date.last_year)
  end

  def best_sellers(limit = 15, date = Date.today)
    products = []
    self.products.each {|e| products << {product: e, sales_ytd: e.sales_ytd(self.user_id, self.id), growth: e.growth(self.user_id, self.id)}}
    products.sort_by {|e| e[:sales_ytd]}.reverse[0..(limit - 1)]
  end

  def best_groups(date = Date.today)
    hash = {}
    self.groups.each {|e| hash[e.number] = {
      sales_ytd: e.products.map {|prod| prod.sales_ytd(self.user_id, self.id, date)}.sum,
      growth: e.products.map {|prod| prod.growth(self.user_id, self.id, date.year)}.sum
     }}
    hash.sort_by {|k,v| v["sales_ytd"]}.reverse.to_h
  end

  def age
    (Date.today - self.orders.order(:invoice_date => :desc).last.invoice_date).to_i
  end

  def new_items(date = Date.today)
    self.products.collect {|e| [e.number, e.sales_ytd(self.user_id, self.id, date)] if e.age <= 180}.compact.sort_by {|e| e[1]}.reverse.to_h
  end

  def promo_percentage
    self.orders.where(promo: true).map {|e| e.price * e.quantity}.sum / self.orders.all.map {|e| e.price * e.quantity}.sum
  end

  def sales_numbers(year = Date.today.year, month = Date.today.month)
    numbers = []
    6.times do
      numbers << [
        Date.new(year, month).strftime("%b %Y"),
        self.sales_month(year, month),
        self.sales_month(year - 1, month)
      ]
      if month == 1
        month = 12
        year -= 1
      else
        month -= 1
      end
    end
    numbers.reverse
  end

  def recommendations
    require 'csv'
    @csv = CSV.read('recommendations.csv', headers: true)
    @hash = {}
    @csv.each do |row|
      @customer_id = row["customer_id"]
      @products = row.to_h
      @products.delete("customer_id")
      @products.each {|key, val| @products[key] = val.to_f}
      @hash[@customer_id] = @products
    end
    Pearson.recommendations(@hash, self.id.to_s)
  end

  def self.write_recommendations
    require 'csv'
    @headers = ["customer_id"]
    @arr = []
    Product.all.each {|e| @headers << e.number}
    Customer.all.each do |customer|
      @arr2 = [customer.id]
      Product.all.each do |product|
        @val = product.sales_ytd(nil, customer.id)
        @arr2 << @val
      end
      @arr << @arr2
    end
    CSV.open('recommendations.csv', 'w', headers: true) do |csv|
      csv << @headers
      @arr.each do |a|
        csv << a
      end
    end
  end
end
