require 'test_helper'

class MessageTest < ActiveSupport::TestCase
  test 'create with body' do
    message = messages(:hello)
    assert message.save
  end

  #  test 'create with invalid phone number and message body' do
  #    message = messages(:invalid_number)
  #    assert_not message.save
  #  end
end
