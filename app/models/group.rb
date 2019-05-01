class Group < ApplicationRecord
  has_many :products
  has_many :user_groups
  has_many :users, through: :user_groups
  has_many :customer_groups
  has_many :customers, through: :customer_groups
  has_many :sales_numbers, as: :numberable
  has_many :orders, through: :products

  def get_age
    self.products.maximum(:age)
  end

  def update_sales
    self.update(
      sales_year: self.products.sum(:sales_year),
      prev_sales_year: self.products.sum(:prev_sales_year),
      sales_ytd: self.products.sum(:sales_ytd),
      prev_sales_ytd: self.products.sum(:prev_sales_ytd),
      age: self.get_age,
      quantity: self.products.sum(:quantity)
    )
    self.update(growth: self.sales_year - self.prev_sales_year)
  end

  def self.update_sales
    @groups = Group.all
    @groups.each do |group|
      group.update_sales
    end
  end

  def write_sales_number(month, year)
    sales = self.products.joins(:sales_numbers).where(sales_numbers: {month: month, year: year}).sum(:sales)
    quantity = self.products.joins(:sales_numbers).where(sales_numbers: {month: month, year: year}).sum(:quantity)
    self.sales_numbers.create(month: month, year: year, sales: sales, quantity: quantity)
  end

  def self.write_sales_numbers
    @groups = Group.all.includes(:products)
    @groups.each do |group|
      start_year = group.products.joins(:orders).minimum("orders.invoice_date").year
      end_year = group.products.joins(:orders).maximum("orders.invoice_date").year
      (start_year..end_year).each do |year|
        12.times do |t|
          month = t + 1
          unless group.sales_numbers.where(month: month, year: year).length > 0
            sales = group.products.joins(:sales_numbers).where(sales_numbers: {month: month, year: year}).sum(:sales)
            quantity = group.products.joins(:sales_numbers).where(sales_numbers: {month: month, year: year}).sum(:quantity)
            group.sales_numbers.create(month: month, year: year, sales: sales, quantity: quantity)
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
        self.sales_numbers.where(month: month, year: year).pluck(:sales).first.to_f,
        self.sales_numbers.where(month: month, year: year - 1).pluck(:sales).first.to_f,
        self.sales_numbers.where(month: month, year: year).pluck(:quantity).first,
        self.sales_numbers.where(month: month, year: year - 1).pluck(:quantity).first
      ]
    end
    numbers.reverse
  end

  def self.ordered_sales_numbers(user_id, order_by, start_index, end_index, reverse = true)
    end_date = Order.maximum(:invoice_date)
    sales_year = self.joins(:orders).where("orders.user_id = ? AND invoice_date >= ? AND invoice_date <= ?", user_id, end_date.last_year, end_date).group('groups.id').select('groups.id, groups.number, sum(total) as total_sum').order('total_sum desc').map {|e| [e["id"], [e["number"], e["total_sum"].to_f]]}.to_h

    prev_year = self.joins(:orders).where("orders.user_id = ? AND invoice_date >= ? AND invoice_date <= ?", user_id, end_date.last_year.last_year, end_date.last_year).group('groups.id').select('groups.id, groups.number, sum(total) as total_sum').order('total_sum desc').map {|e| [e["id"], [e["number"], e["total_sum"].to_f]]}.to_h

    sales_arr = sales_year.map {|k,v| prev_year[k]? v << (v[1] - prev_year[k][1]) : v << v[1]}
    if order_by == "sales"
      sales_arr.sort_by! {|e| e[1]}
    elsif order_by == "growth"
      sales_arr.sort_by! {|e| e[2]}
    end
    sales_arr.reverse! if reverse
    return sales_arr[start_index..end_index]
  end
end
