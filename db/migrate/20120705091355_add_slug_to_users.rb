class AddSlugToUsers < ActiveRecord::Migration
  def change
    add_column :users, :slug, :string, :limit => 64
    add_index  :users, :slug
  end
end
