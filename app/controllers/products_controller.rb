class ProductsController < ApplicationController
  def index
    params[:page_number] ? @page_number = params[:page_number].to_i : @page_number = 1
    params[:sort_by] ? @sort_by = params[:sort_by] : @sort_by = "sales"
    if(@sort_by === "sales")
      @products = current_user.user_products.order(:sales_year => :desc)
    elsif @sort_by === "growth"
      @products = current_user.user_products.order(:growth => :desc)
    elsif @sort_by === "number"
      @products = current_user.user_products.order(:number)
    end
    render json: paginate(@products, @page_number)
  end

  def show
    @product = Product.find(params[:id])
    render json: @product
  end
end
