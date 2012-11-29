class RemoveVarietyFromNotes < ActiveRecord::Migration
  def up
    remove_column :notes, :variety
  end

  def down
    add_column :notes, :variety, :string, :limit  => 11
  end
end
