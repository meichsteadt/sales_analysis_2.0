class SalesNumbersController < ApplicationController
  def index
    params[:month] ? @month = params[:month].to_i : @month = Date.today.month
    params[:year] ? @year = params[:year].to_i : @year = Date.today.year
    if params[:customer_id]
      begin
        @sales_numbers = Customer.find(params[:customer_id]).sales_numbers(@year, @month)
      rescue
        @sales_numbers = {"message": "customer not found"}
      end
    elsif params[:product_id]
      @sales_numbers = Product.find(params[:product_id]).sales_numbers(current_user.id, nil, @year, @month)
    else
      @sales_numbers = current_user.sales_numbers(@year, @month)
    end
    render json: @sales_numbers
  end
end
