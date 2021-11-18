class AddPrimaryIdToVeteranRepresentativesTable < ActiveRecord::Migration[6.1]
  def change
    add_column :veteran_representatives, :id, :primary_key
  end
end
