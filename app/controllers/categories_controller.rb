class CategoriesController < ApplicationController
  def show
    params[:page_number] ? @page_number = params[:page_number].to_i : @page_number = 1
    params[:sort_by] ? @sort_by = params[:sort_by] : @sort_by = "sales"
    @products = Product.ordered_sales_numbers(current_user, @sort_by, true, params[:customer_id], params[:name])

    render json: paginate(@products, @page_number)
  end
end
