# Attributes:
# * id [integer, primary, not null, limit=4] - primary key
# * business_id [integer, not null, limit=4] - TODO: document me
# * comment [text] - TODO: document me
# * created_at [datetime, not null] - creation time
# * created_by [integer, limit=4] - TODO: document me
# * owner_type [string, not null] - TODO: document me
# * result [integer, limit=1] - TODO: document me
# * updated_at [datetime, not null] - last update time
class AuditLog < ActiveRecord::Base
  def self.build_log(register_id, type)
    audit_log = AuditLog.find_or_initialize_by_business_id_and_owner_type(register_id, type)
    if audit_log.new_record?
      audit_log.update_attributes!(
        :result => 1,
        :created_by => 4
      )
    end
    return audit_log
  end
end
