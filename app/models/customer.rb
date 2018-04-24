class Customer < ApplicationRecord
  belongs_to :user
  has_many :orders
  has_many :customer_products
  has_many :products, through: :customer_products
  has_many :customer_groups
  has_many :groups, through: :customer_groups
  has_many :sales_numbers, :as => :numberable

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
    numbers
  end

  def product_mix(year = Date.today.year)
    categories = ["dining", "bedroom", "seating", "youth", "occasional", "home"]
    categories_hash = {}
    categories.each do |category|
      if self.products.where(category: category).any?
        categories_hash[category] = self.get_category_sales(category)/self.sales_year
      else
        categories_hash[category] = 0
      end
    end
    categories_hash
  end

  def get_category_sales(category, date = Date.today)
    self.customer_products.joins(:product).where("category = '#{category}'").sum(:sales_year)
  end

  def age
    (Date.today - self.orders.order(:invoice_date => :desc).last.invoice_date).to_i
  end

  def best_sellers

  end

  def new_items(date = Date.today)
    self.products.order(:sales_year => :desc).where("age <= 180")
  end

  def promo_percentage
    self.orders.where(promo: true).sum(:total) / self.orders.sum(:total)
  end

  def recommendations(limit = 50, test_id = nil)
    comps = Recommendation.comparisons(self.id, limit)
    @recommendations = {}
    @sim_sums = {}
    @props_sum = {}
    @customer1_products = {}

    # get customer1 orders into hash {id => sales_year}
    self.customer_products.order(:sales_year => :desc).limit(limit).pluck(:product_id, :sales_year).map {|m| @customer1_products[m[0]] = m[1] unless m[0] == test_id}.reject! {|e| e == nil}

    comps.each do |comp|
      @customer2_products = {}
      if comp[1] > 0
        # get customer2 orders into hash {id => sales_year}
        comp[0].customer_products.order(:sales_year => :desc).limit(limit).pluck(:product_id, :sales_year).map {|m| @customer2_products[m[0]] = m[1]}

        # get id's of missing products
        mi = @customer2_products.map {|k, v| k} - @customer1_products.map {|k, v| k}

        # normalize for different stores sizes
        @c1_sum = self.sales_year
        @c2_sum = comp[0].sales_year
        @size_prop = @c1_sum/@c2_sum

        # loop through each missing product and add customer 2's sales_year for the product time their sim_pearson to the total and add the sum of the sim_pearson to sim_sums
        mi.each do |product_id|
          # don't recommend palette
          unless product_id == 1899
            if @recommendations[product_id]
              @recommendations[product_id] += (@customer2_products[product_id] * comp[1])
              @sim_sums[product_id] += comp[1]
              @props_sum[product_id] << (@size_prop)
            else
              @recommendations[product_id] = ((@customer2_products[product_id] * comp[1]))
              @sim_sums[product_id] = comp[1]
              @props_sum[product_id] = [@size_prop]
            end
          end
        end
      end
    end
    @recommendations.map {|k,v| [k, (v/@sim_sums[k])]}.map {|k,v| [k, (v * @props_sum[k].mean)] if @props_sum[k].length >= 2 }.reject! {|r| r == nil}.sort_by {|s| s[1]}.reverse.first(50).map {|m| Product.find(m[0])}
  end

  def missing_best_sellers(date = Date.today)
    (self.user.products.order(:sales_year => :desc) - self.products.order(:sales_year => :desc)).first(50)
  end

  def missing_new_items(date = Date.today)
    (self.user.new_items - self.new_items)
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
        self.sales_numbers.where(month: month, year: year).pluck(:sales),
        self.sales_numbers.where(month: month, year: year - 1).pluck(:sales)
      ]
    end
    numbers.reverse
  end

  def self.update_sales
    customers = Customer.all.includes(:orders)
    customers.each do |customer|
    end_date = customer.orders.maximum(:invoice_date)
      customer.update(
        sales_year: customer.orders.where('invoice_date <= ? AND invoice_date >= ?', end_date, end_date.last_year).sum(:total),
        prev_sales_year: customer.orders.where('invoice_date <= ? AND invoice_date >= ?', end_date.last_year, end_date.last_year.last_year).sum(:total),
        sales_ytd: customer.orders.where('invoice_date <= ? AND invoice_date >= ?', end_date, end_date.beginning_of_year).sum(:total),
        prev_sales_ytd: customer.orders.where('invoice_date <= ? AND invoice_date >= ?', end_date.last_year, end_date.last_year.beginning_of_year).sum(:total),
      )
      customer.update(growth: customer.sales_year - customer.prev_sales_year)
    end
  end
end
