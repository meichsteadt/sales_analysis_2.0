class MissingBestSellersController < ApplicationController
  def index
    params[:page_number] ? @page_number = params[:page_number].to_i : @page_number = 1
    @customer = Customer.find(params[:customer_id])
    @products = @customer.missing_best_sellers
    @missing_best_sellers = paginate(@products[0..49], @page_number)
    render json: prorate(@missing_best_sellers, @customer)
  end

private
  def prorate(products, customer)
    arr = []
    products[:arr].map { |m|
      sales_year = current_user.user_products.where(id: m.id).pluck(:sales_year).first * (customer.sales_year / current_user.sales_year)
      arr << {
        id: m.id,
        number: m.number,
        sales_year: sales_year}
    }
    {arr: arr, pages: products[:pages]}
  end
end
