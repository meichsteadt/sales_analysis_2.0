class UserGroup < ApplicationRecord
  belongs_to :user
  belongs_to :group
  has_many :sales_numbers, as: :numberable

  def update_sales
    ids = self.group.products.joins(:user_products).where(user_products: {user_id: self.user.id}).ids
    user_products = self.user.user_products.where(product_id: ids)
    sales_year = user_products.sum(:sales_year)
    prev_sales_year = user_products.sum(:prev_sales_year)
    sales_ytd = user_products.sum(:sales_ytd)
    prev_sales_ytd = user_products.sum(:prev_sales_ytd)
    group_number = self.group.number
    category = self.group.category
    self.update(
      number: group_number,
      sales_year: sales_year,
      prev_sales_year: prev_sales_year,
      sales_ytd: sales_ytd,
      prev_sales_ytd: prev_sales_ytd,
      growth: sales_year - prev_sales_year
    )
  end

  def self.update_sales
    UserGroup.all.includes(:group).each do |ug|
      ug.update_sales
    end
  end

  def self.write_sales_numbers
    UserGroup.all.includes(:group).each {|e| e.write_sales_numbers}
  end

  def write_sales_numbers
    ids = self.group.products.pluck(:id)
    user_products = self.user.user_products.where(product_id: ids)
    start_year = self.group.products.joins(:user_products).joins(:orders).minimum(:invoice_date).year
    end_year = self.group.products.joins(:user_products).joins(:orders).maximum(:invoice_date).year
    (start_year..end_year).each do |year|
      12.times do |t|
        month = t + 1
        sales = user_products.joins(:sales_numbers).where(sales_numbers: {month: month, year: year}).sum(:sales)
        unless self.sales_numbers.where(month: month, year: year).any?
          self.sales_numbers.create(month: month, year: year, sales: sales)
        else
          self.sales_numbers.find_by(month: month, year: year).update(sales: sales)
        end
      end
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
        self.sales_numbers.where(month: month, year: year - 1).pluck(:sales).first.to_f
      ]
    end
    numbers.reverse
  end
end
