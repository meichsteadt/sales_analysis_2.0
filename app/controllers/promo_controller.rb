class PromoController < ApplicationController
  def index
    render json: {promo_percentage: current_user.promo_percentage}
  end
end
