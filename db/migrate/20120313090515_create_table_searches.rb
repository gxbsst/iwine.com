class CreateTableSearches < ActiveRecord::Migration
  def up
    create_table :searches, :force => true do |t|
      t.string :keywords
      t.timestamps
    end
  end

  def down
    drop_table :searches
  end
end