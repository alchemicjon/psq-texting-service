class MessagesController < ApplicationController
  def create
    message = Message.create message_params
    if message.persisted? 
      render json: message
    else
      render json: { errors: message.errors }, status: :bad_request
    end
  end

  private

  def message_params
    params.require(:message).permit(:phone_number, :message_body)
  end
end
