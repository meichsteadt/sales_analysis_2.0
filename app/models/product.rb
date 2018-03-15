class Product < ApplicationRecord
  belongs_to :group
  has_many :orders
  has_and_belongs_to_many :users
  has_and_belongs_to_many :customers
end
