class SalesNumber < ApplicationRecord
  belongs_to :numberable, polymorphic: true

  def self.write_sales_numbers
    @customers = Customer.all.includes(:orders)
    @customers.each do |customer|
      start_year = customer.orders.order(:invoice_date).first.invoice_date.year
      end_year = customer.orders.order(:invoice_date => :desc ).first.invoice_date.year
      (start_year..end_year).each do |year|
        12.times do |t|
          month = t + 1
          unless customer.sales_numbers.where(month: month, year: year).length > 0
            sales = customer.orders.where("invoice_date >= ? AND invoice_date <= ?", Date.new(year, month), Date.new(year, month).end_of_month).sum(:total)
            quantity = customer.orders.where("invoice_date >= ? AND invoice_date <= ?", Date.new(year, month), Date.new(year, month).end_of_month).sum(:quantity)
            customer.sales_numbers.create(month: month, year: year, sales: sales, quantity: quantity)
          end
        end
      end
    end

    @products = Product.all.includes(:orders)
    @products.each do |product|
      start_year = product.orders.minimum(:invoice_date).year
      end_year = product.orders.maximum(:invoice_date).year
      (start_year..end_year).each do |year|
        12.times do |t|
          month = t + 1
          unless product.sales_numbers.where(month: month, year: year).length > 0
            sales = product.orders.where("invoice_date >= ? AND invoice_date <= ?", Date.new(year, month), Date.new(year, month).end_of_month).sum(:total)
            quantity = product.orders.where("invoice_date >= ? AND invoice_date <= ?", Date.new(year, month), Date.new(year, month).end_of_month).sum(:quantity)
            product.sales_numbers.create(month: month, year: year, sales: sales, quantity: quantity)
          end
        end
      end
    end

    @groups = Group.all.includes(:products)
    @groups.each do |group|
      start_year = group.products.joins(:orders).minimum("orders.invoice_date").year
      end_year = group.products.joins(:orders).maximum("orders.invoice_date").year
      (start_year..end_year).each do |year|
        12.times do |t|
          month = t + 1
          unless group.sales_numbers.where(month: month, year: year).length > 0
            sales = group.products.joins(:sales_numbers).where(sales_numbers: {month: month, year: year}).sum(:sales)
            quantity = group.products.joins(:sales_numbers).where(sales_numbers: {month: month, year: year}).sum(:quantity)
            group.sales_numbers.create(month: month, year: year, sales: sales, quantity: quantity)
          end
        end
      end
    end
  end
end
