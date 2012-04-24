class AddOriginNameToWineRegionTrees < ActiveRecord::Migration
  def change
    add_column :wine_region_trees, :origin_name, :string, :limit => 45
  end
end
