class User < ApplicationRecord
  has_secure_password
  has_many :orders
  has_many :customers
  has_many :user_products
  has_many :products, through: :user_products
  has_many :user_groups
  has_many :groups, through: :user_groups
  has_many :sales_numbers, :as => :numberable

  def category_sales(category, date = Date.today)
    self.products.where(category: category).map {|e| e.sales_ytd(self.id, nil, date)}.sum
  end

  def age
    (Date.today - self.orders.order(:invoice_date => :desc).last.invoice_date).to_i
  end

  def new_items
    self.products.order(:sales_year => :desc).where("age <= 180")
  end

  def promo_percentage
    self.orders.where(promo: true).sum(:total) / self.orders.sum(:total)
  end

  def get_category_sales(category, date = Date.today)
    self.products.where(category: category).sum(:sales_year)
  end

  def product_mix(year = Date.today.year)
    categories = ["dining", "bedroom", "seating", "youth", "occasional", "home"]
    categories_hash = {}
    categories.each do |category|
      if self.products.where(category: category).any?
        categories_hash[category] = self.get_category_sales(category)/self.sales_year
      else
        categories_hash[category] = 0
      end
    end
    categories_hash
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

  def update_sales
    @orders = self.orders
    self.update(
      sales_ytd: @orders.where('invoice_date <= ? AND invoice_date >= ?', Date.today, Date.today.beginning_of_year).sum(:total),
      prev_sales_ytd: @orders.where('invoice_date <= ? AND invoice_date >= ?', Date.today.last_year, Date.today.last_year.beginning_of_year).sum(:total),
      sales_year: @orders.where('invoice_date <= ? AND invoice_date >= ?', Date.today, Date.today.last_year).sum(:total),
      prev_sales_year: @orders.where('invoice_date <= ? AND invoice_date >= ?', Date.today.last_year, Date.today.last_year.last_year).sum(:total)
    )
    self.update(growth: self.sales_year - self.prev_sales_year)
  end

  def update_sales_numbers
    orders = self.orders
    start_year = orders.minimum(:invoice_date).year
    end_year = orders.maximum(:invoice_date).year
    (start_year..end_year).each do |year|
      12.times do |t|
        month = t + 1
        unless self.sales_numbers.where(month: month, year: year).any?
          sales = orders.where("invoice_date >= ? AND invoice_date <= ?", Date.new(year, month), Date.new(year, month).end_of_month).sum(:total)
          self.sales_numbers.create(month: month, year: year, sales: sales)
        end
      end
    end
  end

end
