class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def new_sales_numbers
    end_date = self.orders.maximum(:invoice_date)
    numbers = self.orders
    .where("invoice_date >= ? AND invoice_date <= ?", end_date.next_month.last_year.last_year.beginning_of_month, end_date)
    .group("extract(year from invoice_date)")
    .group("extract(month from invoice_date)")
    .select("extract(year from invoice_date) as year, extract(month from invoice_date) as month, sum(total) as sum_total, sum(orders.quantity) as sum_quant")
    .order("year desc, month desc")
    .map do |e|
      date = Date.new(e["year"], e["month"])
      year = date.year
      month = date.month
      @sales_number = SalesNumber.new(
        year: year,
        month: month,
        sales: e["sum_total"],
        quantity: e["sum_quant"],
      )
    end

    numbers.first(12).map do |m|
      prev_year = numbers.select do |s|
        s if s.month == m.month && s != m
      end.first
      [
        Date.new(m.year, m.month).strftime("%b %Y"),
        m.sales,
        prev_year.sales,
        m.quantity,
        prev_year.quantity,
      ]
    end
  end

end
