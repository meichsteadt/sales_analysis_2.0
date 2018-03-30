class CategoriesController < ApplicationController
  def index
    params[:limit] ? @limit = params[:limit] : @limit = 15
    @categories = {}
    ["dining", "bedroom", "seating", "youth", "occasional", "home"].each do |category|
      @products = []
      if params[:customer_id]
        Customer.find(params[:customer_id]).products.where(category: category).each {|e| @products << {product: e, sales_ytd: e.sales_ytd(nil, params[:customer_id]), growth: e.growth(nil, params[:customer_id])}}
      else
        current_user.products.where(category: category).each {|e| @products << {product: e, sales_ytd: e.sales_ytd(current_user.id, nil), growth: e.growth(current_user.id, nil)}}
      end
      @categories[category] = @products.sort_by {|e| e[:sales_ytd]}.reverse[0..(@limit - 1)]
    end
    render json: @categories
  end

  def show
    params[:limit] ? @limit = params[:limit] : @limit = 15
    @products = []
    if params[:customer_id]
      Customer.find(params[:customer_id]).products.where(category: params[:name]).each {|e| @products << {product: e, sales_ytd: e.sales_ytd(nil, params[:customer_id]), growth: e.growth(nil, params[:customer_id])}}
    else
      current_user.products.where(category: params[:name]).each {|e| @products << {product: e, sales_ytd: e.sales_ytd(current_user.id, nil), growth: e.growth(current_user.id, nil)}}
    end
    render json: @products.sort_by {|e| e[:sales_ytd]}.reverse[0..(@limit - 1)]
  end
end
