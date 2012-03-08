class WineVarietiesRenameNameToNameZh < ActiveRecord::Migration
  def up
    rename_column :wine_varieties, :name, :name_zh
  end

  def down
    rename_column :wine_varieties, :name_zh, :name
  end
end