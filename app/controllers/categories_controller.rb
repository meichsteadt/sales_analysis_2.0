class CategoriesController < ApplicationController
  def show
    params[:page_number] ? @page_number = params[:page_number].to_i : @page_number = 1
    params[:sort_by] ? @sort_by = params[:sort_by] : @sort_by = "sales"
    per_page = 10
    pages = 5
    start_index = (@page_number - 1) * per_page
    end_index = start_index + per_page
      @products = Product.where(category: params[:name]).ordered_sales_numbers(customer_id, @sort_by, start_index, end_index, false, params[:customer_id])
    end

    render json: {arr: @products, pages: pages}
  end
end
