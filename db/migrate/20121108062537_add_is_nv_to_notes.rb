class AddIsNvToNotes < ActiveRecord::Migration
  def change
    add_column :notes, :is_nv, :boolean, :default => false
  end
end
