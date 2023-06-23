class Message < ApplicationRecord
  validates :body, presence: true

  belongs_to :phone_number
end
