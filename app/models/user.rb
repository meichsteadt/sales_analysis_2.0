class User < ApplicationRecord
  has_secure_password
  has_many :orders
  has_many :customers
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
        categories_hash[category] = (self.products.where(category: category).map {|e| e.sales_year(self.id, nil, year)}.sum / self.sales_year(year))
      else
        categories_hash[category] = 0
      end
    end
    categories_hash
  end

  def category_sales(category, date = Date.today)
    self.products.where(category: category).map {|e| e.sales_ytd(self.id, nil, date)}.sum
  end

  def growth(year = Date.today.year)
    self.sales_ytd(year) - self.sales_ytd(year - 1)
  end

  def best_sellers(limit = 15, date = Date.today)
    products = []
    self.products.each {|e| products << {product: e, sales_ytd: e.sales_ytd(self.id, nil)}}
    products.sort_by {|e| e[:sales_ytd]}.reverse[0..limit - 1]
  end

  def best_groups(date = Date.today)
    hash = {}
    self.groups.each {|e| hash[e.number] = {
      sales_ytd: e.products.map {|prod| prod.sales_ytd(self.id, nil, date)}.sum,
      growth: e.products.map {|prod| prod.growth(self.id, nil, date.year)}.sum
     }}
    hash.sort_by {|k,v| v[:sales_ytd]}.reverse.to_h
  end

  def age
    (Date.today - self.orders.order(:invoice_date => :desc).last.invoice_date).to_i
  end

  def new_items(date = Date.today)
    self.products.collect {|e| [e.number, e.sales_ytd(self.id, nil, date)] if e.age <= 180}.compact.sort_by {|e| e[1]}.reverse.to_h
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

end
