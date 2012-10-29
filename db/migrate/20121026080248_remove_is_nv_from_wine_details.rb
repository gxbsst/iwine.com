class RemoveIsNvFromWineDetails < ActiveRecord::Migration
  def up
    remove_column :wine_details, :is_nv
  end

  def down
    add_column :wine_details, :is_nv, :boolean
  end
end
