class CustomerGroup < ApplicationRecord
  belongs_to :customer
  belongs_to :group

  def update_sales
    ids = self.group.products.joins(:customer_products).where(customer_products: {customer_id: self.customer.id}).ids
    customer_products = self.customer.customer_products.where(product_id: ids)
    sales_year = customer_products.sum(:sales_year)
    prev_sales_year = customer_products.sum(:prev_sales_year)
    sales_ytd = customer_products.sum(:sales_ytd)
    prev_sales_ytd = customer_products.sum(:prev_sales_ytd)

    quantity = customer_products.sum(:quantity)
    prev_quantity = customer_products.sum(:prev_quantity)
    quantity_ytd = customer_products.sum(:quantity_ytd)
    prev_quantity_ytd = customer_products.sum(:prev_quantity_ytd)

    customer_name = self.customer.name
    group_number = self.group.number
    category = self.group.category
    self.update(
      name: customer_name,
      number: group_number,
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
      quantity_growth_ytd: sales_year - prev_sales_year,
      category: category
    )
  end

  def self.update_sales
    @customer_groups = CustomerGroup.all
    @customer_groups.each do |cg|
      cg.update_sales
    end
  end
end
