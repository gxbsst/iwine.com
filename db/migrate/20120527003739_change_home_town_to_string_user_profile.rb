class ChangeHomeTownToStringUserProfile < ActiveRecord::Migration
  def change
    change_column :user_profiles, :hometown, :string, :limit => 150
    change_column :user_profiles, :gender, :string, :limit => 1
  end
end
