class AddUserIdToWineDetails < ActiveRecord::Migration
  def change
    add_column :wine_details, :user_id, :integer, :default => -1 #清晰数据时设置为-1

  end
end
