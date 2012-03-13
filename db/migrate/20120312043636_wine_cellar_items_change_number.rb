class WineCellarItemsChangeNumber < ActiveRecord::Migration
  def up
    change_column :user_wine_cellar_items, :number, :integer, :default => 0
  end

  def down
    change_column :user_wine_cellar_items, :number, :string
  end
end