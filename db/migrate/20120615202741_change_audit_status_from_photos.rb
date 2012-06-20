class ChangeAuditStatusFromPhotos < ActiveRecord::Migration
  def up
    change_column :photos, :audit_status, :integer, :default => 0, :limit => 11
  end

  def down
  end
end
