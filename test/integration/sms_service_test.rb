require 'test_helper'

class SmsServiceTest < ActionDispatch::IntegrationTest
  def setup
    @service = SmsService.new
    @message = messages(:hello)
    @provider_url = 'https://mock-text-provider.parentsquare.com/provider1'
    @provider_url_two = 'https://mock-text-provider.parentsquare.com/provider2'
    @message_id = SecureRandom.uuid
    stub_request(:any, @provider_url)
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
    stub_request(:any, @provider_url)
      .to_return(status: 500, body: JSON.generate({ error: 'Something went wrong' }))
    stub_request(:any, @provider_url_two)
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
    stub_request(:any, @provider_url)
      .to_return(status: 500, body: JSON.generate({ error: 'Something went wrong' }))
    stub_request(:any, @provider_url_two)
      .to_return(status: 200, body: JSON.generate({ message_id: @message_id }))
    @service.call(@message)
    assert_requested :post, @provider_url, times: 1
    assert_requested :post, @provider_url_two, times: 1
    assert(@service.success?)
  end
end
