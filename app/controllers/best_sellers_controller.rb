class BestSellersController < ApplicationController
  def index
    params[:limit] ? @limit = params[:limit] - 1 : @limit = 14
    if params[:customer_id]
      begin
        @best_sellers = Customer.find(params[:customer_id]).best_sellers(@limit)
      rescue
        @best_sellers = {"message": "customer not found"}
      end
    else
      @best_sellers = current_user.best_sellers(current_user.id, @limit)
    end
    render json: @best_sellers
  end
end
