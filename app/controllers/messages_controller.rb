class MessagesController < ApplicationController
  def create
    message = Message.create message_params
    if message.persisted?
      service = SmsService.new
      service.call message
      if service.success?
        render json: { data: message }, status: :created
      else
        render json: { message: 'Unable to send message at this time, please try again' },
               status: :internal_server_error
      end
    else
      render json: { errors: message.errors }, status: :bad_request
    end
  end

  private

  def message_params
    params.require(:message).permit(:phone_number, :message_body)
  end
end
