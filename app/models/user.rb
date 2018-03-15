class User < ApplicationRecord
  has_secure_password
  has_many :orders
  has_many :customers
  has_and_belongs_to_many :products
  has_and_belongs_to_many :groups
end
