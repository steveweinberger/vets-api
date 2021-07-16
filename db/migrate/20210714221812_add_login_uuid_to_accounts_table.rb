class AddLoginUuidToAccountsTable < ActiveRecord::Migration[6.0]
  def change
    add_column :accounts, :login_uuid, :string
  end
end
