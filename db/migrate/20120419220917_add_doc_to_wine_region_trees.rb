class AddDocToWineRegionTrees < ActiveRecord::Migration
  def change
    add_column :wine_region_trees, :doc, :string, :limit => 30
  end
end
