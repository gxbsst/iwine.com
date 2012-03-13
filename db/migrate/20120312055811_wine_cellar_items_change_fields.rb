class WineCellarItemsChangeFields < ActiveRecord::Migration
  def up
    change_column :user_wine_cellar_items, :buy_date, :datetime
    change_column :user_wine_cellar_items, :drinkable_begin, :datetime
    change_column :user_wine_cellar_items, :drinkable_end, :datetime    
  end

  def down
    change_column :user_wine_cellar_items, :buy_date, :string
    change_column :user_wine_cellar_items, :drinkable_begin, :integer
    change_column :user_wine_cellar_items, :drinkable_end, :integer     
  end
end