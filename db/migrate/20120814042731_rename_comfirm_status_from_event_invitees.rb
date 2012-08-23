class RenameComfirmStatusFromEventInvitees < ActiveRecord::Migration
  def up
    rename_column :event_invitees, :comfirm_status, :confirm_status
  end

  def down
    rename_column :event_invitees, :confirm_status, :comfirm_status
  end
end
