class AddVarietyToNotes < ActiveRecord::Migration
  def change
    add_column :notes, :variety, :string, :limit  => 11
  end
end
