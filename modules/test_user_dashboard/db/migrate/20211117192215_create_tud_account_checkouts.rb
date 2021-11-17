class CreateTudAccountCheckouts < ActiveRecord::Migration[6.1]
  def change
    create_table :test_user_dashboard_tud_account_checkouts do |t|
      t.string :account_uuid
      t.timestamp :checkout_time
      t.timestamp :checkin_time, null: true
      t.boolean :has_checkin_error, :is_manual_checkin, null: true
      t.timestamps
    end
  end
end
