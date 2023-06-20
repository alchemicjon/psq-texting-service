require 'test_helper'

class MessageTest < ActiveSupport::TestCase
  test 'create with valid phone number and message body' do
    message = messages(:valid)
    assert message.save
  end

  test 'create with invalid phone number and message body' do
    message = messages(:invalid_number)
    assert_not message.save
  end

  test 'phone numbers are saved in normalized format' do
    message = Message.create(phone_number: '855-251-5727', message_body: 'Hello world')
    assert message.phone_number.eql? '+18552515727'
  end
end
