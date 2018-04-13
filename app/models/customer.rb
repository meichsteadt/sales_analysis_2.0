class Customer < ApplicationRecord
  belongs_to :user
  has_many :orders
  has_many :customer_products
  has_many :products, through: :customer_products
  has_many :customer_groups
  has_many :groups, through: :customer_groups
  has_many :sales_numbers, :as => :numberable

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
    numbers
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

  def get_category_sales(category, date = Date.today)
    self.customer_products.joins(:product).where("category = '#{category}'").sum(:sales_year)
  end

  def age
    (Date.today - self.orders.order(:invoice_date => :desc).last.invoice_date).to_i
  end

  def best_sellers

  end

  def new_items(date = Date.today)
    self.products.order(:sales_year => :desc).where("age <= 180")
  end

  def promo_percentage
    self.orders.where(promo: true).sum(:total) / self.orders.sum(:total)
  end

  def recommendations
    @products = Product.all.pluck(:id)
    @hash = {}
    @customers = Customer.all.includes(:customer_products)
    @customers.each do |customer|
      @hash[customer.id] = {}
      @products.each do |id|
        if customer.customer_products.pluck(:product_id).include?(id)
          @hash[customer.id][id] = customer.customer_products.where(product_id: id).pluck(:sales_year)[0]
        else
          @hash[customer.id][id] = 0
        end
      end
    end
    @hash
    Pearson.recommendations(@hash, self.id)
  end

  def missing_best_sellers(date = Date.today)
    (self.user.products.order(:sales_year => :desc) - self.products.order(:sales_year => :desc)).first(50)
  end

  def missing_new_items(date = Date.today)
    (self.user.new_items - self.new_items)
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
        self.sales_numbers.where(month: month, year: year).pluck(:sales),
        self.sales_numbers.where(month: month, year: year - 1).pluck(:sales)
      ]
    end
    numbers.reverse
  end

  def self.update_sales
    customers = Customer.all.includes(:orders)
    customers.each do |customer|
      customer.update(
        sales_year: customer.orders.where('invoice_date <= ? AND invoice_date >= ?', Date.today, Date.today.last_year).sum(:total),
        prev_sales_year: customer.orders.where('invoice_date <= ? AND invoice_date >= ?', Date.today.last_year, Date.today.last_year.last_year).sum(:total),
        sales_ytd: customer.orders.where('invoice_date <= ? AND invoice_date >= ?', Date.today, Date.today.beginning_of_year).sum(:total),
        prev_sales_ytd: customer.orders.where('invoice_date <= ? AND invoice_date >= ?', Date.today.last_year, Date.today.last_year.beginning_of_year).sum(:total),
      )
      customer.update(growth: customer.sales_year - customer.prev_sales_year)
    end
  end
end
