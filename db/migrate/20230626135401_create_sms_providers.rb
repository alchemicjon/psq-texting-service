class CreateSmsProviders < ActiveRecord::Migration[7.0]
  def change
    create_table :sms_providers, id: :uuid do |t|
      t.string :url
      t.integer :attempts

      t.timestamps
    end
  end
end
