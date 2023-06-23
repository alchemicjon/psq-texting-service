require 'rest-client'

class SmsService
  attr_reader :errors, :response, :callback_url

  def initialize
    @success = nil
    @response = nil
    @errors = []
    @provider_url = 'https://mock-text-provider.parentsquare.com/provider1'
    @provider_url_two = 'https://mock-text-provider.parentsquare.com/provider2'
    @callback_url = "https://#{ENV.fetch('PUBLIC_URL', nil)}/messages/delivery_callback"
    @headers = { content_type: :json }
  end

  def call(message)
    return unless check_valid_message(message)

    url = @provider_url
    count = 0
    begin
      send_sms_request(message, url)
    rescue RestClient::ExceptionWithResponse => e
      if count < 1
        url = @provider_url_two
        count += 1
        retry
      else
        handle_exception e
      end
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
    if message.respond_to?(:phone_number) == false
      @errors.push 'No phone number provided'
    elsif message.phone_number.can_send == false
      @errors.push 'Cannot send to this number'
    elsif message.respond_to?(:body) == false
      @errors.push 'No message body provided'
    end

    @success = @errors.empty?
  end

  def payload(message)
    JSON.generate({
      to_number: message.phone_number.number,
      message: message.body,
      callback_url: @callback_url
    })
  end

  def send_sms_request(message, url)
    @response = RestClient.post(url, payload(message), @headers)
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
