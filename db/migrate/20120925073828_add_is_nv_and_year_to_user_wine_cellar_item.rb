class AddIsNvAndYearToUserWineCellarItem < ActiveRecord::Migration
  def change
    add_column :user_wine_cellar_items, :year, :datetime
    add_column :user_wine_cellar_items, :is_nv, :boolean
  end
end
