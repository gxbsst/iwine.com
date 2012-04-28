class AddDoToComment < ActiveRecord::Migration
  def self.up
    add_column :comments, :do, :string, :default => "comment" # maybe follow
    add_index :comments, [:do] 
  end

  def self.down
    remove_column :comments,
  end
end
