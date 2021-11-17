class DropTestUserDashboardTudAccountsCheckins < ActiveRecord::Migration[6.1]
  def change
    drop_table :test_user_dashboard_tud_accounts_checkins
  end
end
