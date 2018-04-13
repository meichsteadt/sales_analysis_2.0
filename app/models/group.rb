class Group < ApplicationRecord
  has_many :products
  has_many :user_groups
  has_many :users, through: :user_groups
  has_many :customer_groups
  has_many :customers, through: :customer_groups
  has_many :sales_numbers, as: :numberable

  def get_age
    self.products.maximum(:age)
  end

  def self.update_sales
    @groups = Group.all
    @groups.each do |group|
      group.update(
        sales_year: group.products.sum(:sales_year),
        prev_sales_year: group.products.sum(:prev_sales_year),
        sales_ytd: group.products.sum(:sales_ytd),
        prev_sales_ytd: group.products.sum(:prev_sales_ytd),
        age: group.get_age
      )
      group.update(growth: group.sales_year - group.prev_sales_year)
    end
  end

  def get_sales_numbers(date = Date.today)
    numbers = []
    12.times do |time|
      if date.month - time > 0
        month = date.month - time
        year = date.year
      else
        month = date.month - time + 12
        year = date.year - 1
      end
      numbers << [
        Date.new(year, month).strftime("%b %Y"),
        self.sales_numbers.where(month: month, year: year).pluck(:sales).first,
        self.sales_numbers.where(month: month, year: year - 1).pluck(:sales).first
      ]
    end
    numbers.reverse
  end

end
