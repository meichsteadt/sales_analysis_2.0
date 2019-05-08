class Order < ApplicationRecord
  belongs_to :product
  belongs_to :customer
  belongs_to :user

  def self.within_year(end_date = Order.maximum(:invoice_date))
    where("invoice_date >= ? AND invoice_date <= ?", end_date.last_year, end_date)
  end
end
