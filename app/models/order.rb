class Order < ApplicationRecord
  belongs_to :product
  belongs_to :customer
  belongs_to :user
end
