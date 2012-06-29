class AddIsPublicToAlbums < ActiveRecord::Migration
  def change
  	 add_column :albums, :is_public, :integer, :limit => 1, :default => 1
  end
end
