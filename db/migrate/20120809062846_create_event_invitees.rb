# encoding: utf-8
class CreateEventInvitees < ActiveRecord::Migration
  def change
    create_table :event_invitees do |t|
      t.belongs_to :user
      t.belongs_to :event
      t.integer :comfirm_status, :default => 0 # 0 => 未确认，1 => 已经确认
      t.text :invite_log # 向用户发送邀请的信息

      t.timestamps
    end
    add_index :event_invitees, :user_id
    add_index :event_invitees, :event_id
  end
end
