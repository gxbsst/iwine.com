class ChangeLimitOfPhotoTypeFromPhotos < ActiveRecord::Migration
  def up
    change_column :photos, :photo_type, :integer, :default => 0, :limit => 11
  end

  def down
  end
end
