class AddStatusToMessage < ActiveRecord::Migration[7.0]
  def change
    add_column :messages, :status, :string
  end
end
