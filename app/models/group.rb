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

  def update_sales
    self.update(
      sales_year: self.products.sum(:sales_year),
      prev_sales_year: self.products.sum(:prev_sales_year),
      sales_ytd: self.products.sum(:sales_ytd),
      prev_sales_ytd: self.products.sum(:prev_sales_ytd),
      age: self.get_age,
      quantity: self.products.sum(:quantity)
    )
    self.update(growth: self.sales_year - self.prev_sales_year)
  end

  def self.update_sales
    @groups = Group.all
    @groups.each do |group|
      group.update_sales
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
        self.sales_numbers.where(month: month, year: year).pluck(:sales).first.to_f,
        self.sales_numbers.where(month: month, year: year - 1).pluck(:sales).first.to_f,
        self.sales_numbers.where(month: month, year: year).pluck(:quantity).first,
        self.sales_numbers.where(month: month, year: year - 1).pluck(:quantity).first
      ]
    end
    numbers.reverse
  end

end
