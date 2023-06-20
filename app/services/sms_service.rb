require 'httparty'
require 'pry'

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
    unless message.respond_to?(:phone_number) && message.respond_to?(:message_body)
      @success = false
      @errors.push 'You need to pass a message to SmsService'
      return
    end
    body = {
      to_number: message.phone_number,
      message: message.message_body,
      callback_url: @callback_url
    }
    @options[:body] = JSON.generate(body)
    @response = HTTParty.post(
      @provider_uri,
      @options
    )
    unless @success = @response.success?
      @errors.push @response.parsed_response
    end
    success?
  end

  def success?
    !!@success
  end

  def failure?
    !@success
  end
end
