class ChangeErrorInfoToTextFromOauthComments < ActiveRecord::Migration
  def up
  	 change_column :oauth_comments, :error_info, :text
  end

  def down
  end
end
