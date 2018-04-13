class CategoriesController < ApplicationController
  # Need this???
  def index
    params[:page_number] ? @page_number = params[:page_number].to_i : @page_number = 1
    @categories = {}
    ["dining", "bedroom", "seating", "youth", "occasional", "home"].each do |category|
      if params[:customer_id]
        @products = Customer.find(params[:customer_id]).customer_products.joins(:product).where(products: {category: category}).order(:sales_year => :desc)
      else
        @products = current_user.user_products.joins(:products).where(products: {category: category}).order(:sales_year => :desc)
      end
      @categories[category] = @products
    end
    render json: @categories
  end

  def show
    params[:page_number] ? @page_number = params[:page_number].to_i : @page_number = 1
    params[:sort_by] ? @sort_by = params[:sort_by] : @sort_by = "sales"
    if params[:customer_id]
      @products = Customer.find(params[:customer_id]).customer_products
    else
      @products = current_user.user_products
    end
    if @sort_by === "sales"
      @products = @products.joins(:product).where(products: {category: params[:name]}).order(:sales_year => :desc)
    elsif @sort_by === "growth"
      @products = @products.joins(:product).where(products: {category: params[:name]}).order(:growth => :desc)
    elsif @sort_by === "number"
      @products = @products.joins(:product).where(products: {category: params[:name]}).order(:sales_year => :desc).limit(50).sort_by {|e| e.number}
    end
    render json: paginate(@products.first(50), @page_number)
  end
end
