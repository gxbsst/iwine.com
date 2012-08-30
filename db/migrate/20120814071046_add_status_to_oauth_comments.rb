class AddStatusToOauthComments < ActiveRecord::Migration
  def change
    add_column :oauth_comments, :status, :integer, :limit => 2, :default => 0 #未同步
  end
end
