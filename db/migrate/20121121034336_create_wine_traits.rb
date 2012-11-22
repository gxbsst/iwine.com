class CreateWineTraits < ActiveRecord::Migration
  def change
    create_table :wine_traits do |t|
      t.integer :parent_id
      t.string :key
      t.string :name_zh
      t.string :name_en

      t.timestamps
    end
  end
end
