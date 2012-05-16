class UserTimeline < ActiveRecord::Migration
  def up
    create_table :user_timelines, :force => true do |t|
      t.integer :user_id, :null => false
      t.integer :timeline_event_id, :null => false
      t.timestamps
    end
    add_index :user_timelines, :user_id
  end

  def down
    drop_table :user_timelines
  end
end