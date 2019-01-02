class SalesNumber < ApplicationRecord
  belongs_to :numberable, polymorphic: true

  def self.write_sales_numbers
    Customer.write_sales_numbers
    # Product.write_sales_numbers
    # Group.write_sales_numbers
  end
end
