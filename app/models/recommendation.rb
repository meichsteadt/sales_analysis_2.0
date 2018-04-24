class Recommendation
  def sim_pearson(customer1_orders, customer2_orders)
    @customer1_products = {}
    @customer2_products = {}
    customer1_orders.pluck(:product_id, :sales_year).map {|e| @customer1_products[e[0]] = e[1]}
    customer2_orders.pluck(:product_id, :sales_year).map {|e| @customer2_products[e[0]] = e[1]}

    si = @customer1_products.map {|k, v| k} & @customer2_products.map {|k, v| k}
    n = si.length

    if n == 0; return 0; end

    arr1 = []
    arr2 = []
    arr3 = []
    si.each do |id|
      arr1 << @customer1_products[id]
      arr2 << @customer2_products[id]
      arr3 << @customer1_products[id] * @customer2_products[id]
    end

    sum1 = arr1.sum
    sum2 = arr2.sum

    sum1Sq = arr1.map {|e| e**2}.sum
    sum2Sq = arr2.map {|e| e**2}.sum

    pSum = arr3.sum

    num = pSum - (sum1*sum2/n)
    den = Math.sqrt((sum1Sq - ((sum1**2)/n))*(sum2Sq - ((sum2**2)/n)))
    if den == 0; return 0; end

    r=num/den
  end

  def timer()
    time = Time.now
    Recommendation.comparisons(80)
    Time.now - time
  end

  def self.comparisons(customer_id, limit)
    @r = Recommendation.new()
    @c1 = Customer.find(customer_id)
    @customers = @c1.user.customers.where("sales_year > 48000").includes(:customer_products)
    @comps = {}
    @customers.map {|e| @comps[e] = @r.sim_pearson(@c1.customer_products.order(:sales_year => :desc).limit(limit), e.customer_products.order(:sales_year => :desc).limit(limit)) if @c1 != e}
    @comps.sort_by {|k,v| v }
  end
end
