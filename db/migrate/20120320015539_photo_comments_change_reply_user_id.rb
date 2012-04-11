class PhotoCommentsChangeReplyUserId < ActiveRecord::Migration
  def up
    rename_column :photo_comments, :reply_user_id, :reply_id
  end

  def down
    rename_column :photo_comments, :reply_id, :reply_user_id
  end
end
