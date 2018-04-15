class CustomerProduct < ApplicationRecord
  belongs_to :customer
  belongs_to :product

  def self.update_sales
    @customer_products = CustomerProduct.all
    @customer_products.each do |cp|
      orders = Order.where(customer_id: cp.customer_id, product_id: cp.product_id)
      end_date = orders.maximum(:invoice_date)
      sales_year = orders.where("invoice_date >= ? AND invoice_date <= ?", end_date.last_year, end_date).sum(:total)
      prev_sales_year = orders.where("invoice_date >= ? AND invoice_date <= ?", end_date.last_year.last_year, end_date.last_year).sum(:total)
      sales_ytd = orders.where("invoice_date >= ? AND invoice_date <= ?", end_date.beginning_of_year, end_date).sum(:total)
      prev_sales_ytd = orders.where("invoice_date >= ? AND invoice_date <= ?", end_date.beginning_of_year.last_year, end_date.last_year).sum(:total)
      customer_name = cp.customer.name
      product_number = cp.product.number
      cp.update(
        name: customer_name,
        number: product_number,
        sales_year: sales_year,
        prev_sales_year: prev_sales_year,
        sales_ytd: sales_ytd,
        prev_sales_ytd: prev_sales_ytd,
        growth: sales_year - prev_sales_year
      )
    end
  end
end
