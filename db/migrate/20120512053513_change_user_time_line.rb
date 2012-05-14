class ChangeUserTimeLine < ActiveRecord::Migration
  def up
    rename_column :user_timelines, :about_with, :ownerable_type # 关于谁的动作， 有User, WineDetail, Winery
    rename_column :user_timelines, :wine_detail_id, :ownerable_id
    add_column :user_timelines, :receiver, :string
    add_column :user_timelines, :receiver_id, :integer
    add_column :user_timelines, :event_type, :string

    add_index :user_timelines, :receiver_id
    add_index :user_timelines, :event_type
  end

  def down
    rename_column :user_timelines, :ownerable_type, :about_with
    rename_column :user_timelines, :ownerable_type, :about_with
    remove_column :user_timelines, :receiver
    remove_column :user_timelines, :receiver_id
    remove_column :user_timelines, :event_type
  end
end
