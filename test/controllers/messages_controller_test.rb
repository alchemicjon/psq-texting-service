require 'test_helper'

class MessagesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @valid_phone = '8552515727'
    @invalid_phone = '1234567890'
    @provider_one = sms_providers(:one)
    @provider_two = sms_providers(:two)
    stub_request(:any, /.*provider.*/)
      .to_return(status: 200, body: JSON.generate({ message_id: 'abc123' }))
  end

  test 'create with new phone number and message body succeeds' do
    assert_difference('PhoneNumber.count') do
      assert_difference('Message.count') do
        post messages_path, params: { number: @valid_phone, body: 'Hi there' }, as: :json
      end
    end

    assert_response :success
  end

  test 'create with existing phone number and message body succeeds' do
    PhoneNumber.create(number: @valid_phone)
    assert_no_difference('PhoneNumber.count') do
      assert_difference('Message.count') do
        post messages_path, params: { number: @valid_phone, body: 'Hi there' }, as: :json
      end
    end

    assert_response :success
  end

  test 'create without phone number fails' do
    assert_no_difference('Message.count') do
      post messages_path, params: { body: 'Hi there' }, as: :json
    end

    assert_response :bad_request
  end

  test 'create without body fails' do
    assert_no_difference('Message.count') do
      post messages_path, params: { number: @valid_phone }, as: :json
    end

    assert_response :bad_request
  end

  test 'service failed' do
    stub_request(:any, /.*provider.*/)
      .to_return(status: 500, body: JSON.generate({ error: 'Something went wrong' }))
    post messages_path, params: { number: @valid_phone, body: 'Hi there' }, as: :json

    assert_response :bad_request
  end
end
