class UsersController < ApplicationController
  def index
    render json: {
      sales_year: current_user.sales_year,
      last_year: current_user.prev_sales_year,
      growth: current_user.growth
    }
  end
end
