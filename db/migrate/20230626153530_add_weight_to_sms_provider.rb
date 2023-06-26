class AddWeightToSmsProvider < ActiveRecord::Migration[7.0]
  def change
    add_column :sms_providers, :weight, :float
  end
end
