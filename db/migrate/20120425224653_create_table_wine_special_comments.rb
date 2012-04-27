class CreateTableWineSpecialComments < ActiveRecord::Migration
  def up
    create_table "wine_special_comments" do |t|
      t.integer "special_commentable_id"
      t.string "special_commentable_type"
      t.string "name"
      t.string "score", :limit => 11
      t.datetime "drinkable_begin"
      t.datetime "drinkable_end"

      t.timestamps
    end
  end

  def down
    drop_table :wine_special_comments
  end
end
