class CreateMessages < ActiveRecord::Migration[7.0]
  def change
    create_table :messages, id: :uuid do |t|
      t.string :phone_number
      t.string :message_body

      t.timestamps
    end
  end
end
