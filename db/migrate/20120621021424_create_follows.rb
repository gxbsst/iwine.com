class CreateFollows < ActiveRecord::Migration
  def change
    create_table :follows do |t|
      t.string :followable_type, :limit => 32, :null => false
      t.integer :followable_id, :null => false
      t.integer :user_id, :null => false
      t.integer :private_type, :limit => 1
      t.boolean :is_share, :default => true

      t.timestamps
    end
  end
end
