class UserProduct < ApplicationRecord
  belongs_to :user
  belongs_to :product
  has_many :sales_numbers, as: :numberable

  def self.update_sales
    UserProduct.all.each do |up|
      orders = Order.where(user_id: up.user_id, product_id: up.product_id)
      sales_year = orders.where("invoice_date >= ? AND invoice_date <= ?", Date.today.last_year, Date.today).sum(:total)
      prev_sales_year = orders.where("invoice_date >= ? AND invoice_date <= ?", Date.today.last_year.last_year, Date.today.last_year).sum(:total)
      sales_ytd = orders.where("invoice_date >= ? AND invoice_date <= ?", Date.today.beginning_of_year, Date.today).sum(:total)
      prev_sales_ytd = orders.where("invoice_date >= ? AND invoice_date <= ?", Date.today.beginning_of_year.last_year, Date.today.last_year).sum(:total)
      product_number = up.product.number
      up.update(
        number: product_number,
        sales_year: sales_year,
        prev_sales_year: prev_sales_year,
        sales_ytd: sales_ytd,
        prev_sales_ytd: prev_sales_ytd,
        growth: sales_year - prev_sales_year
      )
    end
  end

  def self.write_sales_numbers
    UserProduct.all.each do |up|
      orders = up.product.orders
      start_year = orders.minimum(:invoice_date).year
      end_year = orders.maximum(:invoice_date).year
      (start_year..end_year).each do |year|
        12.times do |t|
          month = t + 1
          unless up.sales_number.where(month: month, year: year).any?
            sales = orders.where("invoice_date >= ? AND invoice_date <= ?", Date.new(year, month), Date.new(year, month).end_of_month).sum(:total)
            up.sales_numbers.create(month: month, year: year, sales: sales)
          end
        end
      end
    end
  end
end
