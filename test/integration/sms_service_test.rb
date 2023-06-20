require 'test_helper'

class SmsServiceTest < ActionDispatch::IntegrationTest
  def setup
    @service = SmsService.new
  end

  test 'it runs' do
    assert @service.call
  end
end
