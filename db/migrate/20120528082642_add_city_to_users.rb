class AddCityToUsers < ActiveRecord::Migration
  def change
    add_column :users, :city, :string, :limit => 64
  end
end
