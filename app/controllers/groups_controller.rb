class GroupsController < ApplicationController
  def index
    params[:customer_id] ? @groups = Customer.find(params[:customer_id]).groups : @groups = current_user.user_groups
    @groups = sort(@groups, params[:sort_by])
    render json: paginate(@groups, @page_number)
  end
end
