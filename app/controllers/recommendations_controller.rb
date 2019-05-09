class RecommendationsController < ApplicationController
  def index
    # params[:page_number] ? @page_number = params[:page_number].to_i : @page_number = 1
    # @customer = Customer.find(params[:customer_id])
    render json: {arr: [], page: 0}
  end
end
