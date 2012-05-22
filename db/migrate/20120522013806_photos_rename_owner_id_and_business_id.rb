class PhotosRenameOwnerIdAndBusinessId < ActiveRecord::Migration
  def self.up
    rename_column :photos, :owner_type, :imageable_type
    rename_column :photos, :business_id, :imageable_id
    change_column :photos, :imageable_type, :string
    add_column :photos, :user_id, :integer
  end

  def self.down
    remove_column :photos, :user_id
    change_column :photos, :imageable_type, :integer
    rename_column :photos, :imageable_id, :business_id
    rename_column :photos, :imageable_type, :owner_type
  end
end