class ChangeAlbumIdPhotos < ActiveRecord::Migration
  def up
    #酒和酒庄没有相册设置为-1
    change_column :photos, :album_id, :integer, :default => -1, :null => true
  end

end
