class CustomersController < ApplicationController
  def index
    params[:page_number] ? @page_number = params[:page_number].to_i : @page_number = 1
    params[:sort_by] ? @sort_by = params[:sort_by] : @sort_by = "sales"
    @customers = current_user.customers.ordered_sales_year(current_user, @sort_by, true, params[:product_id])

    render json: paginate(@customers, @page_number)
  end

  def show
    @customer = Customer.find(params[:id])
    @customer.sales_year = @customer.get_sales_year
    @customer.growth = @customer.get_growth
    if current_user.customers.include?(@customer)
      render json: {customer: @customer,
                  recommendations: [],
                  promo_percentage: @customer.promo_percentage
                }
    else
      render json: {status: "error", code: 401, message: "Unauthorized"}
    end
  end
end
