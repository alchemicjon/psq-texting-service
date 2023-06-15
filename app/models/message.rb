class Message < ApplicationRecord
  validates :phone_number, phone: true
  validates :message_body, presence: true

  before_save :normalize_phone_number

  def formatted_phone_number
    number = Phonelib.parse(phone_number)
    return phone_number if number.invalid?
    number.full_national
  end

  private

  def normalize_phone_number
    self.phone_number = Phonelib.parse(self.phone_number).full_e164.presence
  end
end
