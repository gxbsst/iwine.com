class AddProviderUserIdToUserOauths < ActiveRecord::Migration
  def change
    add_column :user_oauths, :provider_user_id, :string    #保存sns用户的id， sns_user_id 保存 nickname， 这个是历史遗留问题
  end
end
