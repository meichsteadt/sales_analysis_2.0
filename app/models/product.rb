class Product < ApplicationRecord
  belongs_to :group
  has_many :orders
  has_and_belongs_to_many :users
  has_and_belongs_to_many :customers

  def sales_year(user_id, customer_id = nil, year = Date.today.year)
    if customer_id
      self.orders.where("invoice_date >= ? AND invoice_date <= ? AND customer_id = ?", Date.new(year), Date.new(year).end_of_year, customer_id).map {|e| (e.price * e.quantity)}.sum
    else
      self.orders.where("invoice_date >= ? AND invoice_date <= ? AND user_id = ?", Date.new(year), Date.new(year).end_of_year, user_id).map {|e| (e.price * e.quantity)}.sum
    end
  end

  def sales_month(user_id, customer_id = nil, year = Date.today.year, month = Date.today.month)
    if customer_id
      return self.orders.where("invoice_date >= ? AND invoice_date <= ? AND customer_id = ?", Date.new(year, month), Date.new(year, month).end_of_month, customer_id).map {|e| (e.price * e.quantity)}.sum
    else
      return self.orders.where("invoice_date >= ? AND invoice_date <= ? AND user_id = ?", Date.new(year, month), Date.new(year, month).end_of_month, user_id).map {|e| (e.price * e.quantity)}.sum
    end
  end

  def sales_ytd(user_id, customer_id = nil, date = Date.today)
    if customer_id
      self.orders.where("invoice_date >= ? AND invoice_date <= ? AND customer_id = ?", date.last_year, date, customer_id).map {|e| (e.price * e.quantity)}.sum
    else
      self.orders.where("invoice_date >= ? AND invoice_date <= ? AND user_id = ?", date.last_year, date, user_id).map {|e| (e.price * e.quantity)}.sum
    end
  end

  def sales_where(user_id, customer_id = nil, start_month, start_year, end_month, end_year)
    start_date = Date.new(start_year, start_month)
    end_date = Date.new(end_year, end_month).end_of_month
    if customer_id
      self.orders.where("invoice_date >= ? AND invoice_date <= ? AND customer_id = ?", start_date, end_date, customer_id).map {|e| (e.price * e.quantity)}.sum
    else
      self.orders.where("invoice_date >= ? AND invoice_date <= ? AND user_id = ?", start_date, end_date, user_id).map {|e| (e.price * e.quantity)}.sum
    end
  end

  def growth(user_id, customer_id = nil, date = Date.today)
    if customer_id
      self.sales_ytd(nil, customer_id, date) - self.sales_ytd(nil, customer_id, date.last_year)
    else
      self.sales_ytd(user_id, nil, date) - self.sales_ytd(user_id, nil, date.last_year)
    end
  end

  def age
    (Date.today - self.orders.order(:invoice_date => :desc).last.invoice_date).to_i
  end

  def sales_numbers(user_id, customer_id = nil, year = Date.today.year, month = Date.today.month)
    numbers = []
    6.times do
      if customer_id
        numbers << [
          Date.new(year, month).strftime("%b %Y"),
          self.sales_month(nil, customer_id, year, month),
          self.sales_month(nil, customer_id, year - 1, month)
        ]
      else
        numbers << [
          Date.new(year, month).strftime("%b %Y"),
          self.sales_month(user_id, nil,  year, month),
          self.sales_month(user_id, nil,  year - 1, month)
        ]
      end
      if month == 1
        month = 12
        year -= 1
      else
        month -= 1
      end
    end
    numbers.reverse
  end

  def best_customers(date = Date.today)
    @customers = []
    self.customers.each {|e| @customers << {customer: e, sales_ytd: self.sales_ytd(nil, e.id, date), growth: self.growth(nil, e.id, date)}}
    @customers.sort_by {|e| e[:sales_ytd]}.reverse
  end

end
