class CustomersController < ApplicationController
  def index
    params[:page_number] ? @page_number = params[:page_number].to_i : @page_number = 1
    params[:sort_by] ? @sort_by = params[:sort_by] : @sort_by = "sales"
    if params[:product_id]
      @product = Product.find(params[:product_id])
      @customers = @product.customer_products.where(customer_id: params[:customer_id]).order(:sales_year => :desc)
    else
      if(@sort_by === "sales")
        @customers = current_user.customers.order(:sales_year => :desc)
      elsif @sort_by === "growth"
        @customers = current_user.customers.order(:growth => :desc)
      elsif @sort_by === "name"
        @customers = current_user.customers.order(:name)
      end
    end
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
