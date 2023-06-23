require 'test_helper'

class PhoneNumberTest < ActiveSupport::TestCase
  test 'create with valid phone number' do
    phone = phone_numbers(:valid)
    assert phone.save
    assert_equal true, phone.can_send
  end

  test 'create with invalid phone number saves, but marks as not sendable' do
    phone = phone_numbers(:invalid)
    assert phone.save
    assert_equal false, phone.can_send
  end

  test 'phone numbers are saved in normalized format' do
    phone = PhoneNumber.create(number: '855-251-5727')
    assert_equal phone.number, '+18552515727'
  end
end
