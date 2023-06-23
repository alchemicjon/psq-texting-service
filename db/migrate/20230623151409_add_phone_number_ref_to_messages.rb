class AddPhoneNumberRefToMessages < ActiveRecord::Migration[7.0]
  def change
    add_reference :messages, :phone_number, null: false, type: :uuid
  end
end
