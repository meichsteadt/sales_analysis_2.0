class CustomerProduct < ApplicationRecord
  belongs_to :customer
  belongs_to :product

  def update_sales
    orders = Order.where(customer_id: self.customer_id, product_id: self.product_id)
    end_date = self.customer.orders.maximum(:invoice_date)
    sales_year = orders.where("invoice_date >= ? AND invoice_date <= ?", end_date.last_year, end_date).sum(:total)
    prev_sales_year = orders.where("invoice_date >= ? AND invoice_date <= ?", end_date.last_year.last_year, end_date.last_year).sum(:total)
    sales_ytd = orders.where("invoice_date >= ? AND invoice_date <= ?", end_date.beginning_of_year, end_date).sum(:total)
    prev_sales_ytd = orders.where("invoice_date >= ? AND invoice_date <= ?", end_date.beginning_of_year.last_year, end_date.last_year).sum(:total)

    quantity = orders.where("invoice_date >= ? AND invoice_date <= ?", end_date.last_year, end_date).sum(:quantity)
    prev_quantity = orders.where("invoice_date >= ? AND invoice_date <= ?", end_date.last_year.last_year, end_date.last_year).sum(:quantity)
    quantity_ytd = orders.where("invoice_date >= ? AND invoice_date <= ?", end_date.beginning_of_year, end_date).sum(:quantity)
    prev_quantity_ytd = orders.where("invoice_date >= ? AND invoice_date <= ?", end_date.beginning_of_year.last_year, end_date.last_year).sum(:quantity)
    customer_name = self.customer.name
    product_number = self.product.number
    self.update(
      name: customer_name,
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
    @customer_products = CustomerProduct.all
    @customer_products.each do |cp|
      cp.update_sales
    end
  end
end
