class WineRetionTreeRenameParrentToParentId < ActiveRecord::Migration
  def up
    rename_column :wine_region_trees, :parent, :parent_id
  end

  def down
    rename_column :wine_region_trees, :parent_id, :parent
  end
end