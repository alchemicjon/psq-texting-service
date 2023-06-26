require 'test_helper'

class SmsServiceTest < ActionDispatch::IntegrationTest
  def setup
    @service = SmsService.new
    @message = messages(:hello)
    @provider_one = sms_providers(:one)
    @provider_two = sms_providers(:two)
    @message_id = SecureRandom.uuid
    stub_request(:any, /.*provider.*/)
      .to_return(status: 200, body: JSON.generate({ message_id: @message_id }))
  end

  test 'without valid message it fails' do
    assert_not(@service.call('blah'))
    assert(@service.failure?)
    assert_includes(@service.errors, 'No phone number provided')
  end

  test 'happy path: success is true' do
    @service.call(@message)
    assert(@service.success?)
  end

  test 'happy path: service updates message with message_id from provider' do
    @service.call(@message)
    @message.reload
    assert_equal(@message_id, @message.message_id)
  end

  test 'sad path: no providers available' do
    stub_request(:any, /.*provider.*/)
      .to_return(status: 500, body: JSON.generate({ error: 'Something went wrong' }))
    @service.call(@message)
    assert(@service.failure?)
    assert_includes(@service.errors, { 'error' => 'Something went wrong' })
  end

  test 'sad path: phone number has can_send set to false' do
    message = messages(:with_bad_number)
    @service.call(message)
    assert(@service.failure?)
    assert_includes(@service.errors, 'Cannot send to this number')
  end

  test 'if one provider fails, try the other one' do
    stub_request(:any, /.*provider.*/)
      .to_return(status: 500, body: JSON.generate({ error: 'Something went wrong' }))
      .then
      .to_return(status: 200, body: JSON.generate({ message_id: @message_id }))
    @service.call(@message)
    assert_requested :post, @provider_one.url, times: 1
    assert_requested :post, @provider_two.url, times: 1
    assert(@service.success?)
  end

  test 'service increments sms provider attempts when called' do
    # Ensure we pick @provider_one
    assert_difference('@service.provider.attempts') do
      @service.call(@message)
    end
  end

  test 'providers are load balanced' do
    run_number = 1000
    run_number.times do
      s = SmsService.new
      s.call(@message)
    end
    @provider_one.reload
    @provider_two.reload
    assert_in_delta(@provider_one.weight, @provider_one.attempts / run_number.to_f, 0.05)
    assert_in_delta(@provider_two.weight, @provider_two.attempts / run_number.to_f, 0.05)
  end
end
