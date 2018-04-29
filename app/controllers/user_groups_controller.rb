class UserGroupsController < ApplicationController
  def index
    params[:page_number] ? @page_number = params[:page_number].to_i : @page_number = 1
    params[:sort_by] ? @sort_by = params[:sort_by] : @sort_by = "sales"
    if(@sort_by === "sales")
      @groups = current_user.user_groups.order(:sales_year => :desc)
    elsif @sort_by === "growth"
      @groups = current_user.user_groups.order(:growth => :desc)
    elsif @sort_by === "number"
      @groups = current_user.user_groups.order(:number)
    end
    render json: paginate(@groups, @page_number)
  end
end
