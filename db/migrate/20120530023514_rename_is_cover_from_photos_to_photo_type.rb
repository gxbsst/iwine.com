class RenameIsCoverFromPhotosToPhotoType < ActiveRecord::Migration
  def up
    rename_column :photos, :is_cover, :photo_type
  end

  def down
    rename_column :photos, :photo_type, :is_cover
  end
end
