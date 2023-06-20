require 'httparty'

class SmsService
  attr_reader :errors, :response

  def initialize
    @success = nil
    @response = nil
    @errors = []
    @provider_uri = 'https://mock-text-provider.parentsquare.com/provider1'
    @callback_url = 'https://example.com/delivery_status'
    @options = { headers: { 'Content-Type' => 'application/json' } }
  end

  def call(message)
    return unless check_valid_message(message)

    @options[:body] = JSON.generate({
      to_number: message.phone_number,
      message: message.message_body,
      callback_url: @callback_url
    })
    @response = HTTParty.post(@provider_uri, @options)
    @errors.push response_body unless (@success = @response.success?)
    update_message(message)
    success?
  end

  def success?
    !!@success
  end

  def failure?
    !@success
  end

  def response_body
    @response.parsed_response
  end

  def message_id
    response_body['message_id']
  end

  private

  def check_valid_message(message)
    return true if message.respond_to?(:phone_number) && message.respond_to?(:message_body)

    @errors.push 'You need to pass a message to SmsService'
    @success = false
  end

  def update_message(message)
    message.update message_id:
  end
end
