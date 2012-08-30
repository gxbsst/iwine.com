class AddColumnsToOauthComments < ActiveRecord::Migration
  def change
    add_column :oauth_comments, :body, :string
    add_column :oauth_comments, :error_info, :string
    add_column :oauth_comments, :sns_user_id, :string
    add_column :oauth_comments, :user_id, :integer
    add_column :oauth_comments, :image_url, :string
    rename_column :oauth_comments, :sns_id, :sns_comment_id
  end
end
