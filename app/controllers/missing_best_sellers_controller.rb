class MissingBestSellersController < ApplicationController
  def index
    params[:page_number] ? @page_number = params[:page_number].to_i : @page_number = 1
    @category = params[:category]
    @display = params[:display]
    @customer = Customer.find(params[:customer_id])
    @products = @customer.missing_best_sellers(@category)
    @missing_best_sellers = paginate(@products[0..49], @page_number)
    render json: prorate(@missing_best_sellers, @customer, @display)
  end

private
  def prorate(products, customer, display = "sales_year")
    arr = []
    products[:arr].map { |m|
      if display === "sales_year" || display.nil?
        to_display = current_user.user_products.find_by(product_id: m.id).sales_year
      elsif display === "quantity"
        to_display = current_user.user_products.find_by(product_id: m.id).quantity
      end
      arr << {
        id: m.id,
        number: m.number,
        sales_year: to_display
      }
    }
    {arr: arr, pages: products[:pages]}
  end
end
