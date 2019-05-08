class ProductsController < ApplicationController
  def index
    params[:page_number] ? @page_number = params[:page_number].to_i : @page_number = 1
    params[:sort_by] ? @sort_by = params[:sort_by] : @sort_by = "sales"
    @products = current_user.products.ordered_sales_numbers(current_user, @sort_by, true, params[:customer_id])

    render json: paginate(@products, @page_number)
  end

  def show
    @product = current_user.user_products.find_by_product_id(params[:id]).product
    @product.sales_year = @product.get_sales_year(current_user.id, false)
    @product.growth = @product.get_growth(current_user.id, false)
    render json: @product
  end
end
