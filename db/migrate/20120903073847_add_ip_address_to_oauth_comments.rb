class AddIpAddressToOauthComments < ActiveRecord::Migration
  def change
    add_column :oauth_comments, :ip_address, "BIGINT"
  end
end
