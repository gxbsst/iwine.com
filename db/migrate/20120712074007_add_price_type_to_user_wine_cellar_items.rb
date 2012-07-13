class AddPriceTypeToUserWineCellarItems < ActiveRecord::Migration
  def change
    add_column :user_wine_cellar_items, :price_type, :string, :default => "CNY", :limit => 30
  end
end
