class ProductMixController < ApplicationController
  def index
    params[:customer_id] ? @user = Customer.find(params[:customer_id]) : @user = current_user
    render json: @user.product_mix
  end
end
