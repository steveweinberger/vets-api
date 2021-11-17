class DropAddTudAccountCheckouts < ActiveRecord::Migration[6.1]
  def change
    drop_table :test_user_dashboard_tud_account_checkouts
  end
end
