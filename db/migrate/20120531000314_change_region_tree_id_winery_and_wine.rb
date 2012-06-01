class ChangeRegionTreeIdWineryAndWine < ActiveRecord::Migration
  def up
    change_column :wineries, :region_tree_id, :integer, :null => true, :limit => 11
    change_column :wines, :region_tree_id, :integer, :null => true, :limit => 11
    change_column :wine_registers, :region_tree_id, :integer, :null => true, :limit => 11
  end

  def down
  end
end
