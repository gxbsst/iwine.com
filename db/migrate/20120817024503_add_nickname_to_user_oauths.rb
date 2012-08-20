class AddNicknameToUserOauths < ActiveRecord::Migration
  def change
    add_column :user_oauths, :nickname, :string, :limit => 128 # save sns user username
  end
end
