class RenameTypeToOwnerTypeAuditLogs < ActiveRecord::Migration
  def up
    rename_column :audit_logs, :type, :owner_type
  end

  def down
    rename_column :audit_logs, :owner_type, :type
  end
end
