class Customer < ApplicationRecord
  belongs_to :user
  has_many :orders
  has_and_belongs_to_many :products
  has_and_belongs_to_many :groups
end
