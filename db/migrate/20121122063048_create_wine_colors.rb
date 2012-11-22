class CreateWineColors < ActiveRecord::Migration
  def change
    create_table :wine_colors do |t|
      t.string :key
      t.integer :parent_id
      t.string :name_zh
      t.string :name_en
      t.string :image

      t.timestamps
    end
  end
end
