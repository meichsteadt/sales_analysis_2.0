class SearchController < ApplicationController
  def index
    render json: search(search_params)
  end

private
  def search(query)
    @results = {}
    @results["customers"] = current_user.customers.where("lower(name) LIKE ?", "%#{query[:query]}%").sort
    @results["products"] = current_user.products.where("lower(number) LIKE ?", "%#{query[:query]}%").sort
    return @results
  end

  def search_params
    params.permit(:query)
  end
end
