class CustomerGroup < ApplicationRecord
  belongs_to :customer
  belongs_to :group

  def self.update_sales
    @customer_groups = CustomerGroup.all
    @customer_groups.each do |cg|
      customer_products = cg.group.products.joins(:customer_products).where(customer_products: {customer_id: cg.customer.id})
      sales_year = customer_products.sum(:sales_year)
      prev_sales_year = customer_products.sum(:prev_sales_year)
      sales_ytd = customer_products.sum(:sales_ytd)
      prev_sales_ytd = customer_products.sum(:prev_sales_ytd)
      customer_name = cg.customer.name
      group_number = cg.group.number
      cg.update(
        name: customer_name,
        number: group_number,
        sales_year: sales_year,
        prev_sales_year: prev_sales_year,
        sales_ytd: sales_ytd,
        prev_sales_ytd: prev_sales_ytd,
        growth: sales_year - prev_sales_year
      )
    end
  end
end
