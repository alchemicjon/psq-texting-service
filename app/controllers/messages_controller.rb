class MessagesController < ApplicationController
  def create
    if create_phone_and_message # assigns @message
      @service = SmsService.new
      @service.call @message
      service_response
    else
      error_response(@errors)
    end
  end

  def update
    @message = Message.find_by message_id: update_params[:message_id]
    @message&.update update_params
  end

  private

  def create_params
    params.require(:message).permit(:body, phone_number_attributes: :number)
  end

  def update_params
    params.require(:message).permit(:status, :message_id)
  end

  def create_phone_and_message
    @errors = []
    parsed_number = Phonelib.parse(params[:number]).full_e164
    phone = PhoneNumber.find_or_create_by number: parsed_number

    begin
      @message = phone.messages.create create_params
    rescue StandardError => e
      @errors.push(e.message)
    end

    @errors.empty?
  end

  def service_response
    if @service.success?
      data = { id: @message.id }
      render json: { data: }, status: :created
    else
      error_response(@service.errors)
    end
  end

  def error_response(errors)
    render json: { message: 'Unable to send message at this time, please try again', errors: },
           status: :bad_request
  end
end
