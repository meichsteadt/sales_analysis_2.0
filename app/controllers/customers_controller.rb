class CustomersController < ApplicationController
  def index
    @customers = []
    if params[:product_id]
      @product = Product.find(params[:product_id])
      @customers = @product.best_customers
    else
      @current_user.customers.map {|e| @customers.push({customer: e, sales_ytd: e.sales_ytd, growth: e.growth, sales_last_year: e.sales_ytd(Date.today.last_year)})}
    end
    render json: @customers.sort_by {|e| e[:sales_ytd]}.reverse
  end

  def show
    @customer = Customer.find(params[:id])
    render json: {customer: @customer, sales_ytd: @customer.sales_ytd, sales_last_year: @customer.sales_ytd(Date.today.last_year), growth: @customer.growth, recommendations: @customer.recommendations, promo_percentage: @customer.promo_percentage}
  end
end
