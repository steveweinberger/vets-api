class CreateVaccines < ActiveRecord::Migration[6.1]
  def change
    create_table :vaccines do |t|
      t.integer :cvx_number, null: false, index: { unique: true }
      t.string :group_name, null: false

      t.timestamps
    end
  end
end
