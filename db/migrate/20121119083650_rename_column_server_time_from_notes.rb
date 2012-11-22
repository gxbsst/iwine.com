class RenameColumnServerTimeFromNotes < ActiveRecord::Migration
  def change
    rename_column(:notes, :serverTime, :modifiedDate)
  end
end
