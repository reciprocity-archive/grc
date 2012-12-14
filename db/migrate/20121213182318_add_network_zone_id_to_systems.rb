class AddNetworkZoneIdToSystems < ActiveRecord::Migration
  def change
    add_column :systems, :network_zone_id, :integer
  end
end
