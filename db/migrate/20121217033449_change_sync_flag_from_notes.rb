class ChangeSyncFlagFromNotes < ActiveRecord::Migration
  def up
    change_column :notes, :sync_flag, :integer, :default => 0
  end

  def down
  end
end
