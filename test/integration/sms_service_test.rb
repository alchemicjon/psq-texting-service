require 'test_helper'

class SmsServiceTest < ActionDispatch::IntegrationTest
  def setup
    @service = SmsService.new
    @message = messages(:valid)
    @provider_url = 'https://mock-text-provider.parentsquare.com/provider1'
    stub_request(:any, @provider_url)
      .to_return(status: 200, body: JSON.generate({ message_id: 'abc123' }))
  end

  test 'without valid message it fails' do
    assert_not(@service.call('blah'))
    assert(@service.failure?)
    assert_includes(@service.errors, 'You need to pass a message to SmsService')
  end

  test 'happy path: success is true' do
    @service.call(@message)
    assert(@service.success?)
    assert_equal(@service.response_body, { 'message_id' => 'abc123' })
  end

  test 'sad path: provider not available' do
    stub_request(:any, @provider_url)
      .to_return(status: 500, body: JSON.generate({ error: 'Something went wrong' }))
    @service.call(@message)
    assert(@service.failure?)
    assert_includes(@service.errors, { 'error' => 'Something went wrong' })
  end
end
