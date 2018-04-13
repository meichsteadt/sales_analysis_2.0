class GroupsController < ApplicationController
  def index
    params[:customer_id] ? @groups = Customer.find(params[:customer_id]).groups : @groups = current_user.groups
    @groups.each {|e| hash[e.number] = e.sales_ytd(current_user)}
    binding.pry
    render json: hash.sort_by {|k,v| v}.reverse.to_h
  end
end
