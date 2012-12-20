class AddOpenidToUserOauths < ActiveRecord::Migration
  def change
    add_column :user_oauths, :openid, :string
    add_column :user_oauths, :openkey, :string
  end
end
