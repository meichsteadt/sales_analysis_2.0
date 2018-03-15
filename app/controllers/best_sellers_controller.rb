class BestSellersController < ApplicationController
  def index
    if params[:customer_id]
      begin
        @best_sellers = current_user.customers.find(params[:customer_id]).best_sellers(current_user.id)
      rescue
        @best_sellers = {"message": "customer not found"}
      end
    else
      @best_sellers = current_user.best_sellers(current_user.id)
    end
    render json: @best_sellers
  end
end
