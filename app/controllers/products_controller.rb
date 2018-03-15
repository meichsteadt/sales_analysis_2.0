class ProductsController < ApplicationController
  def index
    render json: {
      products: current_user.products,
      product_mix: current_user.product_mix,
    }
  end

  def show
    render json: Product.find(params[:id])
  end
end
