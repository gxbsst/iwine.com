class FriendshipsChangeColumns < ActiveRecord::Migration
  def up
    rename_column :friendships, :following, :user_id
    rename_column :friendships, :follower, :follower_id
  end

  def down
    rename_column :friendships, :user_id, :following
    rename_column :friendships, :follower_id, :follower
  end
end