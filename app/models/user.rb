class User < ApplicationRecord
  has_secure_password
  has_many :orders
  has_many :customers
  has_many :user_products
  has_many :products, through: :user_products
  has_many :user_groups
  has_many :groups, through: :user_groups
  has_many :sales_numbers, :as => :numberable
  has_many :notes

  def product_mix
    end_date = self.orders.maximum(:invoice_date)
    orders = self.orders.where("invoice_date >= ? AND invoice_date <= ?", end_date.last_year.last_year, end_date)
    total = orders.sum(:total).to_f
    orders.joins(:product).group("products.category").sum("orders.total").map {|k,v| [k, v.to_f/total]}.to_h
  end

  def get_category_sales(category)
    self.user_products.joins(:product).where(products: {category: category}).sum(:sales_year)
  end

  def get_sales_numbers
    # end_date = self.orders.maximum(:invoice_date)
    # self.orders.where("invoice_date >= ? AND invoice_date <= ?", end_date.last_year.last_year.beginning_of_month, end_date).group("extract(year from invoice_date)").group("extract(month from invoice_date)").sum(:total).to_a.sort_by {|e| [e[0][0], e[0][1], e[0][2]]}.map{|m| [Date.new(m[0][0], m[0][1]).strftime("%b %Y"), m[1]]}
    self.new_sales_numbers
  end

  def sales_year(end_date = self.orders.maximum(:invoice_date))
    self.orders.where("invoice_date >= ? AND invoice_date <= ?", end_date.last_year, end_date).sum(:total)
  end

  def growth
    end_date = self.orders.maximum(:invoice_date)
    self.sales_year(end_date) - self.sales_year(end_date.last_year)
  end

  # def update_sales
  #   @orders = self.orders
  #   end_date = @orders.maximum(:invoice_date)
  #   self.update(
  #     sales_ytd: @orders.where('invoice_date <= ? AND invoice_date >= ?', end_date, end_date.beginning_of_year).sum(:total),
  #     prev_sales_ytd: @orders.where('invoice_date <= ? AND invoice_date >= ?', end_date.last_year, end_date.last_year.beginning_of_year).sum(:total),
  #     sales_year: @orders.where('invoice_date <= ? AND invoice_date >= ?', end_date, end_date.last_year).sum(:total),
  #     prev_sales_year: @orders.where('invoice_date <= ? AND invoice_date >= ?', end_date.last_year, end_date.last_year.last_year).sum(:total),
  #     quantity_ytd: @orders.where('invoice_date <= ? AND invoice_date >= ?', end_date, end_date.beginning_of_year).sum(:quantity),
  #     prev_quantity_ytd: @orders.where('invoice_date <= ? AND invoice_date >= ?', end_date.last_year, end_date.last_year.beginning_of_year).sum(:quantity),
  #     quantity: @orders.where('invoice_date <= ? AND invoice_date >= ?', end_date, end_date.last_year).sum(:quantity),
  #     prev_quantity: @orders.where('invoice_date <= ? AND invoice_date >= ?', end_date.last_year, end_date.last_year.last_year).sum(:quantity)
  #
  #   )
  #   self.update(
  #     growth: self.sales_year - self.prev_sales_year,
  #     growth_ytd: self.sales_ytd - self.prev_sales_ytd,
  #     quantity_growth: self.quantity - self.prev_quantity,
  #     quantity_growth_ytd: self.quantity_ytd - self.prev_quantity_ytd,
  #   )
  #   self.user_products.each {|e| e.update_sales}
  #   self.user_groups.each {|e| e.update_sales}
  # end
end
