class RenamePulishStatusFromEvent < ActiveRecord::Migration
  def up
    rename_column :events, :pulish_status, :publish_status
  end

  def down
    rename_column :events, :publish_status, :pulish_status
  end
end
