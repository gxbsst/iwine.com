class AddExchangeRateIdToNotesAndUserWineCellarItems < ActiveRecord::Migration

  def change
    add_column :user_wine_cellar_items, :exchange_rate_id, :int, :default => nil
    add_column :notes, :exchange_rate_id, :int, :default => nil
  end
  
end
