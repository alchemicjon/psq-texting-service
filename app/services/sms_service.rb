require 'rest-client'
require 'pry'

class SmsService
  attr_reader :errors, :response, :callback_url

  def initialize
    @success = nil
    @response = nil
    @errors = []
    @provider_url = 'https://mock-text-provider.parentsquare.com/provider1'
    @callback_url = "https://#{ENV['PUBLIC_URL']}/messages/delivery_callback"
    @headers = { content_type: :json }
  end

  def call(message)
    return unless check_valid_message(message)

    begin
      @response = RestClient.post(@provider_url, payload(message), @headers)
    rescue RestClient::ExceptionWithResponse => e
      handle_exception e
    else
      handle_success message
    end
    success?
  end

  def success?
    !!@success
  end

  def failure?
    !@success
  end

  private

  def response_body
    JSON.parse(@response.body)
  end

  def message_id
    response_body['message_id']
  end

  def check_valid_message(message)
    return true if message.respond_to?(:phone_number) && message.respond_to?(:message_body)

    @errors.push 'You need to pass a message to SmsService'
    @success = false
  end

  def payload(message)
    JSON.generate({
      to_number: message.phone_number,
      message: message.message_body,
      callback_url: @callback_url
    })
  end

  def handle_success(message)
    @success = true
    message.update message_id:
  end

  def handle_exception(exception)
    @errors.push JSON.parse(exception.response.body)
    @success = false
  end
end
