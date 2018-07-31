class NotesController < ApplicationController
  before_action :set_customer
  def index
    render json: @customer.notes
  end

  def create
    @note = @customer.notes.new(user_id: current_user.id, note: note_params[:note])
    if @note.save!
      render json: {
        response: 200,
        message: "successfully created note"
      }
    else
      render json: {
        response: 204,
        message: "something went wrong"
      }
    end
  end

  def destroy
    @note = Note.find(params[:id])
    if @note.destroy
      render json: {
        response: 200,
        message: "successfully deleted note"
      }
    else
      render json: {
        response: 204,
        message: "something went wrong"
      }
    end
  end

private
  def set_customer
    @customer = Customer.find(params[:customer_id])
  end

  def note_params
    params.permit(:note)
  end
end
