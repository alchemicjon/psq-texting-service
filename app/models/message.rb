class Message < ApplicationRecord
  validates :phone_number, presence: true
  validates :message_body, presence: true
end
