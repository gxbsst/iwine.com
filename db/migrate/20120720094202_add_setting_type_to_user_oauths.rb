class AddSettingTypeToUserOauths < ActiveRecord::Migration
  def change
  	#此字段区分该user_oauth是用户使用第三方登陆创建的，还是用户登陆后绑定的。
    add_column :user_oauths, :setting_type, :int, :limit => 10
  end
end
