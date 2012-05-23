class AddWinesCountToUsers < ActiveRecord::Migration
  def change
    add_column :users, :wines_count, :integer, :limit => 11, :default => 0

  end
end
