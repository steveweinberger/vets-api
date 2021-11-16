class CreateVaccines < ActiveRecord::Migration[6.1]
  def change
    create_table :vaccines do |t|
      t.integer :cvx_code, null: false, index: { unique: true }
      t.string :group_name, null: false
      t.string :manufacturer, null: true

      t.timestamps
    end
  end
end
