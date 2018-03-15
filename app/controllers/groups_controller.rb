class GroupsController < ApplicationController
  def index
    hash = {}
    params[:month] ? @month = params[:month].to_i : @month = Date.today.month
    params[:year] ? @year = params[:year].to_i : @year = Date.today.year
    params[:customer_id] ? @groups = Customer.find(params[:customer_id]).groups : @groups = current_user.groups
    @groups.each {|e| hash[e.number] = e.sales_ytd(current_user)}
    binding.pry
    render json: hash.sort_by {|k,v| v}.reverse.to_h
  end
end
