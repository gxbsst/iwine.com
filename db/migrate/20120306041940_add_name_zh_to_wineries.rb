class AddNameZhToWineries < ActiveRecord::Migration
  def change
    add_column :wineries, :name_zh, :string

  end
end
