class ApplicationController < ActionController::API
  before_action :authenticate_request, :pages
  attr_reader :current_user

private

  def authenticate_request
    @current_user = AuthorizeApiRequest.call(request.headers).result
    render json: { error: 'Not Authorized' }, status: 401 unless @current_user
  end

  def pages
    params[:page_number] ? @page_number = params[:page_number].to_i : @page_number = 1
  end

  def sort(arr, sort_by)
    sort_by ? @sort_by = sort_by : @sort_by = "sales"
    if(@sort_by === "sales")
      return arr.order(:sales_year => :desc)
    elsif @sort_by === "growth"
      return arr.order(:growth => :desc)
    elsif @sort_by === "number"
      return arr.order(:number)
    end
  end

  def paginate(array, page_number, per_page = 10)
    pages = (array.length/per_page).ceil
    start = ((page_number - 1) * per_page)
    stop = start + (per_page - 1)
    {arr: array[start..stop], pages: pages}
  end
end
