class AddPhotosCountToWines < ActiveRecord::Migration
  def change
    add_column :wines, :photos_count, :integer
  end
end
