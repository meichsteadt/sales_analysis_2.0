class ProductsController < ApplicationController
  def index
    @products = []
    @limit = 10
    current_user.products.map {|e| @products.push({product: e, sales_ytd: e.sales_ytd(current_user.id), growth: e.growth(current_user.id)})}
    render json: @products.sort_by {|e| e[:sales_ytd]}.reverse[0..@limit]
  end

  def show
    @product = Product.find(params[:id])
    render json: {product: @product, sales_ytd: @product.sales_ytd(current_user.id, nil), sales_last_year: @product.sales_ytd(current_user.id, nil), growth: @product.growth(current_user.id, nil)}
  end
end
