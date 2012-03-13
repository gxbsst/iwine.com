class AddNumberToUserWineCellarItems < ActiveRecord::Migration
  def change
    add_column :user_wine_cellar_items, :number, :string

  end
end
