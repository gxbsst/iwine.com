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
