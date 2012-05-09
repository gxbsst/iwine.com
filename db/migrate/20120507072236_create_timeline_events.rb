class CreateTimelineEvents < ActiveRecord::Migration
  def self.up
    create_table :timeline_events do |t|
      t.string   :event_type, :subject_type,  :actor_type,  :secondary_subject_type, :secondary_actor_type
      t.integer               :subject_id,    :actor_id,    :secondary_subject_id, :secondary_actor_id
      t.timestamps
    end
    add_index :timeline_events, :event_type
    add_index :timeline_events, :actor_type
    add_index :timeline_events, :secondary_actor_type
    add_index :timeline_events, :subject_id
    add_index :timeline_events, :actor_id
    add_index :timeline_events, :secondary_actor_id
  end
 
  def self.down
    remove_index :timeline_events, :actor_type
    remove_index :timeline_events, :event_type
    remove_index :timeline_events, :secondary_actor_type
    remove_index :timeline_events, :subject_id
    remove_index :timeline_events, :actor_id
    remove_index :timeline_events, :secondary_actor_id   
    drop_table :timeline_events
  end
end
 