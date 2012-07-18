class AddDomainToUsers < ActiveRecord::Migration
  def change
    add_column :users, :domain, :string, :limit => 32
    add_index  :users, :domain
  end
end
