class AddItemsCountToUserWineCellars < ActiveRecord::Migration
  def change
    add_column :user_wine_cellars, :items_count, :integer, :limit => 11, :default => 0

  end
end
