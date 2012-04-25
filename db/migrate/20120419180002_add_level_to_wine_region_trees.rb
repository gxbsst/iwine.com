class AddLevelToWineRegionTrees < ActiveRecord::Migration
  def change
    add_column :wine_region_trees, :level, :integer, :limit => 1, :default => 1, :null => false
  end
end
