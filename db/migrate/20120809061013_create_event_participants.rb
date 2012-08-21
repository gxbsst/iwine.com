class CreateEventParticipants < ActiveRecord::Migration
  def change
    create_table :event_participants do |t|
      t.belongs_to :user
      t.belongs_to :event
      t.string :telephone, :limit => 64, :null => false
      t.string :email, :limit => 64, :null => false
      t.text :note
      t.string :username, :limit => 128, :null => false
      t.integer :join_status, :default => 1 # 1 => 参加, 0 => 取消
      t.text :cancle_note

      t.timestamps
    end
    add_index :event_participants, :user_id
    add_index :event_participants, :event_id
  end
end
