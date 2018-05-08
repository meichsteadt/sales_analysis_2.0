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
      age: self.get_age
    )
    self.orders.where(promo: false).first ? @price = self.orders.where(promo: false).first.price : @price = nil
    self.orders.where(promo: true).first ? @promo_price = self.orders.where(promo: true).first.price : @promo_price = nil
    self.update(price: @price, promo_price: @promo_price)
    self.update(growth: self.sales_year - self.prev_sales_year)
  end

  def self.update_sales
    products = Product.all.includes(:orders)
    products.each do |product|
      product.update_sales
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
end
