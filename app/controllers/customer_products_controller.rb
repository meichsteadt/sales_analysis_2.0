class CustomerProductsController < ApplicationController
  def index
    params[:page_number] ? @page_number = params[:page_number].to_i : @page_number = 1
    params[:sort_by] ? @sort_by = params[:sort_by] : @sort_by = "sales"
    if params[:customer_id]
      @customer = Customer.find(params[:customer_id])
      if(@sort_by === "sales")
        @products = @customer.customer_products.order(:sales_year => :desc)
      elsif @sort_by === "growth"
        @products = @customer.customer_products.order(:growth => :desc)
      elsif @sort_by === "number"
        @products = @customer.customer_products.order(:number)
      end
    elsif params[:product_id]
      @product = Product.find(params[:product_id])
      ids = current_user.customers.pluck(:id)
      if(@sort_by === "sales")
        @products = @product.customer_products.joins(:customer).where(customer_id: ids).order(:sales_year => :desc)
      elsif @sort_by === "growth"
        @products = @product.customer_products.joins(:customer).where(customer_id: ids).order(:growth => :desc)
      elsif @sort_by === "name"
        @products = @product.customer_products.joins(:customer).where(customer_id: ids).order(:name)
      end
    end
    render json: paginate(@products, @page_number)
  end
end
