class AddPinyinToWineVarieties < ActiveRecord::Migration
  def change
    add_column  :wine_varieties, :pinyin, :string
  end
end
