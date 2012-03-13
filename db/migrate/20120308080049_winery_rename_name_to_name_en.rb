class WineryRenameNameToNameEn < ActiveRecord::Migration
  def up
    rename_column :wineries, :name, :name_en
    
  end

  def down
    rename_column :wineries, :name_en, :name
  end
end