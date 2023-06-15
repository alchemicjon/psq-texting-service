require "test_helper"

class MessagesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @valid_phone = '8552515727'
    @invalid_phone = '1234567890'
  end

  test 'create with phone number and message body succeeds' do
    assert_difference("Message.count") do
      post messages_path, params: { phone_number: @valid_phone, message_body: 'Hi there' }, as: :json
    end

    assert_response :success
  end

  test 'create without phone number fails' do
    assert_no_difference("Message.count") do
      post messages_path, params: { message_body: 'Hi there' }, as: :json
    end

    assert_response :bad_request
  end

  test 'create without message_body fails' do
    assert_no_difference("Message.count") do
      post messages_path, params: { phone_number: @valid_phone }, as: :json
    end

    assert_response :bad_request
  end
end
