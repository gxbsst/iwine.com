class AddAboutWithToUserTimelines < ActiveRecord::Migration
  def change
    add_column :user_timelines, :about_with, :string

    add_column :user_timelines, :wine_detail_id, :string

  end
end
