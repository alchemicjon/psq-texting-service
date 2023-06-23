class MessagesController < ApplicationController
  def create
    @message = Message.create create_params
    if @message.persisted?
      @service = SmsService.new
      @service.call @message
      service_response
    else
      render json: { errors: @message.errors }, status: :bad_request
    end
  end

  def update
    @message = Message.find_by message_id: update_params[:message_id]
    @message&.update update_params
  end

  private

  def create_params
    params.require(:message).permit(:phone_number, :message_body)
  end

  def update_params
    params.require(:message).permit(:status, :message_id)
  end

  def service_response
    if @service.success?
      data = { id: @message.id }
      render json: { data: }, status: :created
    else
      render json: { message: 'Unable to send message at this time, please try again', errors: @service.errors },
             status: :internal_server_error
    end
  end
end
