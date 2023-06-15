require 'test_helper'

class MessageTest < ActiveSupport::TestCase
  def setup
    @valid_phone = '8552515727'
    @invalid_phone = '1234567890'
  end

  test 'create with valid phone number and message body' do
    message = Message.new(phone_number: @valid_phone, message_body: 'Hello world')
    assert message.save
  end

  test 'create with invalid phone number and message body' do
    message = Message.new(phone_number: @invalid_phone, message_body: 'Hello world')
    assert_not message.save
  end

  test 'phone numbers are saved in normalized format' do
    message = Message.create(phone_number: '855-251-5727', message_body: 'Hello world')
    assert message.phone_number.eql? '+18552515727'
  end
end
