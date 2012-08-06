class AddSettingTypeToUserOauths < ActiveRecord::Migration
  def change
  	#默认是绑定用户
    add_column :user_oauths, :setting_type, :integer, :limit => 3, :default => APP_DATA['user_oauths']['setting_type']['binding']
  end
end
