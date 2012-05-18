class TimelineChangeNameReceiver < ActiveRecord::Migration
  def up
    rename_column :user_timelines, :receiver, :receiverable_type
    rename_column :user_timelines, :receiver_id, :receiverable_id
  end

  def down
    rename_column :user_timelines, :receiverable_type, :receiver
    rename_column :user_timelines, :receiverable_id, :receiver_id
  end
end