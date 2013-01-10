module Service
  # encoding: utf-8
  class VerifyAudit
    attr_reader :auditor, :user, :audit_log

    ACCEPTED = 2
    REJECTED = 1

    def self.rejected(auditor, user, options = {})
      User.transaction do
        audit_log =  AuditLog.create(:owner_type => OWNER_TYPE_USER,
                                     :business_id => user.id,
                                     :created_by => auditor.id,
                                     :result => REJECTED,
                                     :comment => options[:comment]
        )
        user.accepted(audit_log)
        # send email
      end
    end

    def self.accepted(auditor, user, options = {})
      User.transaction do
        audit_log =  AuditLog.create(:owner_type => OWNER_TYPE_USER,
                                     :business_id => user.id,
                                     :created_by => auditor.id,
                                     :result => ACCEPTED,
                                     :comment => options[:comment]
        )
        user.accepted(audit_log)
        # send email
      end
    end
  end
end
