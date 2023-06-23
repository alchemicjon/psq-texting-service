class CreatePhoneNumbers < ActiveRecord::Migration[7.0]
  def change
    create_table :phone_numbers, id: :uuid do |t|
      t.string :number
      t.boolean :can_send

      t.timestamps
    end

    change_table :messages do |t|
      t.remove :phone_number, :message_body
      t.string :body
    end
  end
end
