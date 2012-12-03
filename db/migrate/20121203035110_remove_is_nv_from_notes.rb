class RemoveIsNvFromNotes < ActiveRecord::Migration
  def up
    remove_column :notes, :is_nv
  end

  def down
    add_column :notes, :is_nv, :boolean, :default => false
  end
end
