class PromoController < ApplicationController
  def index
    # render json: {promo_percentage: current_user.promo_percentage}
    render json: {promo_percentage: nil}
  end
end
