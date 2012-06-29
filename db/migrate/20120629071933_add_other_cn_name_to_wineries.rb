class AddOtherCnNameToWineries < ActiveRecord::Migration
  def change
    add_column :wineries, :other_cn_name, :string
  end
end
