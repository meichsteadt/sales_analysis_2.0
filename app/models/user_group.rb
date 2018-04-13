class UserGroup < ApplicationRecord
  belongs_to :user
  belongs_to :group
  has_many :sales_numbers, as: :numberable

  def self.update_sales
    UserGroup.all.each do |ug|
      user_products = ug.group.products.joins(:user_products).where(user_products: {user_id: ug.user.id})
      sales_year = user_products.sum(:sales_year)
      prev_sales_year = user_products.sum(:prev_sales_year)
      sales_ytd = user_products.sum(:sales_ytd)
      prev_sales_ytd = user_products.sum(:prev_sales_ytd)
      group_number = ug.group.number
      ug.update(
        number: group_number,
        sales_year: sales_year,
        prev_sales_year: prev_sales_year,
        sales_ytd: sales_ytd,
        prev_sales_ytd: prev_sales_ytd,
        growth: sales_year - prev_sales_year
      )
    end
  end

  def self.write_sales_numbers
    UserGroup.all.each do |ug|
      user_products = ug.group.products.joins(:user_products).where(user_products: {user_id: ug.user.id})
      start_year = ug.group.products.joins(:user_products).joins(:orders).minimum(:invoice_date).year
      end_year = ug.group.products.joins(:user_products).joins(:orders).maximum(:invoice_date).year
      (start_year..end_year).each do |year|
        12.times do |t|
          month = t + 1
          unless ug.sales_numbers.where(month: month, year: year).any?
            sales = user_products.joins(:sales_numbers).where(sales_numbers: {month: month, year: year}).sum(:sales)
            ug.sales_numbers.create(month: month, year: year, sales: sales)
          end
        end
      end
    end
  end
end
