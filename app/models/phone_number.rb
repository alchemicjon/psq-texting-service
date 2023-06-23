class PhoneNumber < ApplicationRecord
  has_many :messages, dependent: :destroy

  validates :number, presence: true

  before_save :check_phone_number

  def formatted_phone_number
    n = Phonelib.parse(number)
    return number if n.invalid?

    n.full_national
  end

  private

  def check_phone_number
    self.number = Phonelib.parse(number).full_e164.presence
    self.can_send = Phonelib.valid?(number)
  end
end
