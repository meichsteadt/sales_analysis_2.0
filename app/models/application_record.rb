class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def sales_year(user_id, year = Date.today.year)
    self.orders.where("invoice_date >= ? AND invoice_date <= ? AND user_id = ?", Date.new(year), Date.new(year).end_of_year, user_id).map {|e| (e.price * e.quantity)}.sum
  end

  def sales_month(user_id, year = Date.today.year, month = Date.today.month)
    self.orders.where("invoice_date >= ? AND invoice_date <= ? AND user_id = ?", Date.new(year, month), Date.new(year, month).end_of_month, user_id).map {|e| (e.price * e.quantity)}.sum
  end

  def sales_ytd(user_id, date = Date.today)
    self.orders.where("invoice_date >= ? AND invoice_date <= ? AND user_id = ?", date.last_year, date, user_id).map {|e| (e.price * e.quantity)}.sum
  end

  def sales_where(user_id, start_month, start_year, end_month, end_year)
    start_date = Date.new(start_year, start_month)
    end_date = Date.new(end_year, end_month).end_of_month
    self.orders.where("invoice_date >= ? AND invoice_date <= ? AND user_id = ?", start_date, end_date, user_id).map {|e| (e.price * e.quantity)}.sum
  end

  def product_mix(user_id, year = Date.today.year)
    categories = ["dining", "bedroom", "seating", "youth", "occasional", "home"]
    categories_hash = {}
    categories.each do |category|
      if self.products.where(category: category).any?
        categories_hash[category] = (self.products.where(category: category).map {|e| e.sales_year(user_id, year)}.sum / self.sales_year(user_id, year))
      end
    end
    categories_hash
  end

  def category_sales(user_id, category, date = Date.today)
    self.products.where(category: category).map {|e| e.sales_ytd(user_id, date)}.sum
  end

  def growth(user_id, year = Date.today.year)
    self.sales_year(user_id, year) - self.sales_year(user_id, year - 1)
  end

  def best_sellers(user_id, date = Date.today)
    hash = {}
    self.products.each {|e| hash[e.number] = e.sales_ytd(user_id, date)}
    hash.sort_by {|k,v| v}.reverse.to_h
  end

  def best_groups(user_id, date = Date.today)
    hash = {}
    self.groups.each {|e| hash[e.number] = {
      sales_ytd: e.products.map {|prod| prod.sales_ytd(user_id, date)}.sum,
      growth: e.products.map {|prod| prod.growth(user_id, date.year)}.sum
     }}
    hash.sort_by {|k,v| v["sales_ytd"]}.reverse.to_h
  end

  def age
    (Date.today - self.orders.order(:invoice_date => :desc).last.invoice_date).to_i
  end

  def new_items(user_id, ate = Date.today)
    self.products.collect {|e| [e.number, e.sales_ytd(user_id, date)] if e.age <= 180}.compact.sort_by {|e| e[1]}.reverse.to_h
  end

  def sales_numbers(user_id, year = Date.today.year, month = Date.today.month)
    numbers = {}
    12.times do
      numbers[Date.new(year, month).strftime("%b")] = [self.sales_month(user_id, year, month), self.sales_month(user_id, year - 1, month)]
      if month == 1
        month = 12
        year -= 1
      else
        month -= 1
      end
    end
    numbers
  end

end
