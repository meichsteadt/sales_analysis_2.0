class BestSellersController < ApplicationController
  def index
    params[:page_number] ? @page_number = params[:page_number].to_i : @page_number = 1
    if params[:customer_id]
      begin
        @best_sellers = Customer.find(params[:customer_id]).best_sellers
      rescue
        @best_sellers = {"message": "customer not found"}
      end
    else
      @best_sellers = current_user.best_sellers(current_user.id)
    end
    render json: paginate(@best_sellers, @page_number)
  end
end
