class RemoveTypeFromAlbums < ActiveRecord::Migration
  def up
    remove_column :albums, :type
  end

  def down
    add_column :albums, :type, :integer
  end
end