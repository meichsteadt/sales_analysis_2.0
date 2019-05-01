class CustomersController < ApplicationController
  def index
    params[:page_number] ? @page_number = params[:page_number].to_i : @page_number = 1
    params[:sort_by] ? @sort_by = params[:sort_by] : @sort_by = "sales"
    @customers = Customer.ordered_sales_year(current_user.id, @sort_by, true, params[:product_id])

    render json: paginate(@customers, @page_number)
  end

  def show
    @customer = Customer.find(params[:id])
    render json: {customer: @customer,
                  recommendations: [],
                  promo_percentage: @customer.promo_percentage
                }
  end
end
