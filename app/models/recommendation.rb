class Recommendation
  def sim_pearson(customer1, customer2)
    @customer1_products = {}
    @customer2_products = {}
    customer1.customer_products.order(:sales_year => :desc).limit(100).pluck(:product_id, :sales_year).map {|e| @customer1_products[e[0]] = e[1]}
    customer2.customer_products.order(:sales_year => :desc).limit(100).pluck(:product_id, :sales_year).map {|e| @customer2_products[e[0]] = e[1]}

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
    den = Math.sqrt((sum1Sq - sum1**2/n)*(sum2Sq - sum2**2/n))
    if den == 0; return 0; end

    r=num/den
    r
  end

  def timer()
    time = Time.now
    Recommendation.comparisons
    Time.now - time
  end

  def self.comparisons
    @r = Recommendation.new()
    @customers = Customer.where("sales_year > 15000").includes(:customer_products)
    @c1 = Customer.find(27)
    @comps = {}
    @customers.map {|e| @comps[e.id] = @r.sim_pearson(@c1, e) if @c1 != e}
    @comps.sort_by {|k,v| v }
  end
end
