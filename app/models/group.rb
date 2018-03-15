class Group < ApplicationRecord
  has_many :products
  has_and_belongs_to_many :users
  has_and_belongs_to_many :customers

  def sales_ytd(user_id, date = Date.today)
    products.map {|prod| prod.orders.where("invoice_date >= ? AND invoice_date <= ? AND user_id = ?", date.last_year, date, user_id).map {|e| (e.price * e.quantity)}.sum}.sum
  end
end
