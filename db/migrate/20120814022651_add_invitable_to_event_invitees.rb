class AddInvitableToEventInvitees < ActiveRecord::Migration
  def up 
    add_column :event_invitees, :invitable_type, :string
    add_column :event_invitees, :inviter_id, :integer
    rename_column :event_invitees, :event_id, :invitable_id 
    rename_column :event_invitees, :user_id, :invitee_id 
  end

  def down
    remove_column :event_invitees, :invitabl_type
    remove_column :event_invitees, :inviter_id
    rename_column :event_invitees, :invitable_type, :event_id
    rename_column :event_invitees, :invitee_id, :user_id
  end
end
