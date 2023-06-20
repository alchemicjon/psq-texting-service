class AddMessageIdToMessage < ActiveRecord::Migration[7.0]
  def change
    add_column :messages, :message_id, :uuid
  end
end
