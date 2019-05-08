class UserProduct < ApplicationRecord
  belongs_to :user
  belongs_to :product
  has_many :sales_numbers, as: :numberable
  has_many :orders, -> (user_product) { where user_id: user_product.user_id}, through: :product

  def get_user_id
    self.user_id
  end

  def get_sales_numbers(date = Date.today)
    # numbers = []
    # 12.times do |time|
    #   if date.month - time > 0
    #     month = date.month - time
    #     year = date.year
    #   else
    #     month = date.month - time + 12
    #     year = date.year - 1
    #   end
    #   numbers << [
    #     Date.new(year, month).strftime("%b %Y"),
    #     self.sales_numbers.where(month: month, year: year).pluck(:sales).first.to_f,
    #     self.sales_numbers.where(month: month, year: year - 1).pluck(:sales).first.to_f,
    #     self.sales_numbers.where(month: month, year: year).pluck(:quantity).first,
    #     self.sales_numbers.where(month: month, year: year - 1).pluck(:quantity).first
    #   ]
    # end
    # numbers.reverse
    self.new_sales_numbers
  end

  def update_sales
    orders = self.orders
    end_date = self.user.orders.maximum(:invoice_date)
    sales_year = orders.within_year.sum(:total)
    prev_sales_year = orders.where("invoice_date >= ? AND invoice_date <= ?", end_date.last_year.last_year, end_date.last_year).sum(:total)
    sales_ytd = orders.where("invoice_date >= ? AND invoice_date <= ?", end_date.beginning_of_year, end_date).sum(:total)
    prev_sales_ytd = orders.where("invoice_date >= ? AND invoice_date <= ?", end_date.beginning_of_year.last_year, end_date.last_year).sum(:total)

    quantity = orders.within_year.sum(:quantity)
    prev_quantity = orders.where("invoice_date >= ? AND invoice_date <= ?", end_date.last_year.last_year, end_date.last_year).sum(:quantity)
    quantity_ytd = orders.where("invoice_date >= ? AND invoice_date <= ?", end_date.beginning_of_year, end_date).sum(:quantity)
    prev_quantity_ytd = orders.where("invoice_date >= ? AND invoice_date <= ?", end_date.beginning_of_year.last_year, end_date.last_year).sum(:quantity)

    product_number = self.product.number

    self.update(
      number: product_number,
      sales_year: sales_year,
      prev_sales_year: prev_sales_year,
      sales_ytd: sales_ytd,
      prev_sales_ytd: prev_sales_ytd,
      growth: sales_year - prev_sales_year,
      growth_ytd: sales_ytd - prev_sales_ytd,
      quantity: quantity,
      prev_quantity: prev_quantity,
      quantity_ytd: quantity_ytd,
      prev_quantity_ytd: prev_quantity_ytd,
      quantity_growth: quantity - prev_quantity,
      quantity_growth_ytd: quantity_ytd - prev_quantity_ytd
    )
  end

  def self.update_sales
    self.all.each do |up|
      up.update_sales
    end
  end

  def self.write_sales_numbers(user_id)
    orders = Order.where(user_id: user_id)
    UserProduct.where(user_id: user_id).each {|e| e.write_sales_numbers(orders)}
  end

  def write_sales_numbers(all_orders)
    orders = all_orders.where(product_id: self.product_id)
    end_year = [(Date.today.year), orders.maximum(:invoice_date).year].max
    start_year = [(end_year - 1), orders.minimum(:invoice_date).year].min
    (start_year..end_year).each do |year|
      12.times do |t|
        month = t + 1
        unless (month > Date.today.month && year == Date.today.year)
          sales = orders.where("invoice_date >= ? AND invoice_date <= ?", Date.new(year, month), Date.new(year, month).end_of_month).sum(:total)
          quantity = orders.where("invoice_date >= ? AND invoice_date <= ?", Date.new(year, month), Date.new(year, month).end_of_month).sum(:quantity)
          unless self.sales_numbers.where(month: month, year: year).any?
            self.sales_numbers.create(month: month, year: year, sales: sales, quantity: quantity)
          else
            self.sales_numbers.find_by(month: month, year: year).update(sales: sales, quantity: quantity)
          end
        end
      end
    end
  end
end
