class AddConfigToUserProfile < ActiveRecord::Migration
  def change
    add_column :user_profiles, :_config, :text
  end
end
