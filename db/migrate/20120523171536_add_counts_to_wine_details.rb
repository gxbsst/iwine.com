class AddCountsToWineDetails < ActiveRecord::Migration
  def change
    add_column :wine_details, :photos_count, :integer, :limit => 11, :default => 0
    add_column :wine_details, :comments_count, :integer, :limit => 11, :default => 0
    add_column :wine_details, :followers_count, :integer, :limit => 11, :default => 0
    add_column :wine_details, :owners_count, :integer, :limit => 11, :default => 0
    add_column :wine_details, :tasting_notes_count, :integer, :limit => 11, :default => 0
    add_column :wine_details, :events_count, :integer, :limit => 11, :default => 0

    add_column :photos, :views_count, :integer, :limit => 11, :default => 0
    add_column :photos, :comments_count, :integer, :limit => 11, :default => 0
    add_column :photos, :votes_count, :integer, :limit => 11, :default => 0

    add_column :wineries, :wines_count, :integer, :limit => 11, :default => 0
    add_column :wineries, :photos_count, :integer, :limit => 11, :default => 0
    add_column :wineries, :comments_count, :integer, :limit => 11, :default => 0
    add_column :wineries, :followers_count, :integer, :limit => 11, :default => 0

    add_column :users, :photos_count, :integer, :limit => 11, :default => 0
    add_column :users, :wine_followings_count, :integer, :limit => 11, :default => 0 #关注的酒
    add_column :users, :winery_followings_count, :integer, :limit => 11, :default => 0 #关注的酒庄
    add_column :users, :comments_count, :integer, :limit => 11, :default => 0
    add_column :users, :tasting_notes_count, :integer, :limit => 11, :default => 0
    add_column :users, :followings_count, :integer, :limit => 11, :default => 0
    add_column :users, :followers_count, :integer, :limit => 11, :default => 0
    add_column :users, :albums_count, :integer, :limit => 11, :default => 3 #默认初始化三个相册

    add_column  :albums, :photos_count, :integer, :limit => 11, :default => 0
    add_column :comments, :children_count, :integer, :limit => 11, :default => 0


    remove_column :photos, :viewed_num
    remove_column :photos, :commented_num
    remove_column :photos, :liked_num

  end
end
