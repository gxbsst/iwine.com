class AddAgreeTermToUsers < ActiveRecord::Migration
  def change
    add_column :users, :agree_term, :boolean, :default => true
  end
end
