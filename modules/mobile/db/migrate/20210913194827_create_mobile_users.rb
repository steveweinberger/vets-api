class CreateMobileUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :mobile_users do |t|
      t.string :user_id, null: false
      t.datetime :created_at, null: false
      t.index [:user_id], name: "mobile_user_index", unique: true
    end
  end
end
