class AddPhotosCountToEvents < ActiveRecord::Migration
  def change
    add_column :events, :photos_count, :integer, :default => 0
  end
end
