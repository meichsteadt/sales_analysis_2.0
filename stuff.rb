@product = Product.find(138)
@customer = Customer.find(95)
@customer_products = @product.customer_products.includes(:customer)
@avgs = @customer_products.map { |e| e.sales_year == 0.0 ? 0.0 : (e.sales_year/e.customer.sales_year)}.sort.each_slice(@customer_products.length/5).to_a.map {|e| e.sum/e.length}
@customer_sales = @customer_products.map {|e| e.customer.sales_year}.sort.each_slice(@customer_products.length/5).to_a.map {|e| e.sum/e.length}
@diffs = @customer_sales.map {|e| (e - @customer.sales_year).abs}
@index = @diffs.index(@diffs.min)
@avgs[@index]


@avgs = @customer_products.map { |e| e.sales_year == 0.0 ? 0.0 : (e.sales_year/e.customer.sales_year)}



categories = {specialists: {}, generalists: {}}
n_tops = []
Customer.where("sales_year > 15000").includes(:customer_products).each do |c|
  prop = 0
  i = 0
  products = c.customer_products.order(:sales_year => :desc).pluck(:sales_year)
  sy = c.sales_year
  while prop < 0.7 do
    prop += products[i]/sy
    i+=1
  end
  if(sy/i > 1000)
    categories[:specialists][c.id] = sy/i
  else
    categories[:generalists][c.id] = sy/i
  end
end


def top(customer, p_stop)
  p = 0
  n = 0
  @customer = customer
  @products = @customer.customer_groups.order(:sales_year => :desc)
  @sales_year = @customer.sales_year
  while p < p_stop
    if @products[n]
      p += @products[n].sales_year/@sales_year
      n += 1
    else
      break
    end
  end
  n
end

def go
  User.first.customers.where("sales_year > 48000").map {|e| top(e, 0.8)}.mean
end


def test
  n = 50
  results = {}
  customers = Customer.where("sales_year > 48000")
  while n < 200
    results[n] = []
    customers.each do |customer|
    i = Random.rand(10)
    test_product = customer.customer_products.order(:sales_year => :desc)[i].product
      results[n] << customer.recommendations(n, test_product.id)
    end
    n += 10
  end
  results.map {|k,v| [k, v.mean]}.sort_by {|k,v| v}.to_h
end
