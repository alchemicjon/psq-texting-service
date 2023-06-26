require 'rest-client'

class SmsService
  attr_reader :errors, :response, :provider

  def initialize
    @success = nil
    @response = nil
    @errors = []
    @provider_attempts = []
    select_provider
    @callback_url = "https://#{ENV.fetch('PUBLIC_URL', nil)}/messages/delivery_callback"
    @headers = { content_type: :json }
  end

  def call(message)
    return unless check_valid_message(message)

    count = 0
    begin
      send_sms_request(message)
    rescue RestClient::ExceptionWithResponse => e
      if count < SmsProvider.count - 1
        select_provider
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

  def select_provider
    # Select which provider to use based on weight and whether
    # that provider has been attempted during #call already
    providers = SmsProvider.where.not(id: @provider_attempts)
    total = 0.0
    ranges = providers.map { |p| [total += p.weight, p.id] }
    selected = Random.new.rand(providers.sum(:weight))
    id = ranges.find { |num, _id| num > selected }.last
    @provider = providers.find_by(id:)
    @provider_attempts.push @provider.id
  end

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

  def send_sms_request(message)
    payload = JSON.generate({
      to_number: message.phone_number.number,
      message: message.body,
      callback_url: @callback_url
    })
    @provider.increment(:attempts) && @provider.save
    @response = RestClient.post(@provider.url, payload, @headers)
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
