class ChangeWineryToNullWineRegistersAndWines < ActiveRecord::Migration
  def up
    change_column :wine_registers, :winery_id, :int, :limit => 11, :null => true
    change_column :wines, :winery_id, :int, :limit => 11, :null => true
  end

  def down
  end
end
