class User
  module Verifiable
    extend ActiveSupport::Concern

    ACCEPTED = 2
    REJECTED = 1

    included do
      has_one :verify, dependent: :destroy
    end

    def verified?
      audit? && verify.audit_log_result == ACCEPTED
    end

    def audit?
      !verify.audit_log_result.nil?
    end

    def audit_log
      ::AuditLog.where(:owner_type => OWNER_TYPE_USER, :business_id => id).last
    end

    def audit_log_comment
      audit_log.comment
    end

    def accepted(audit_log)
      sync_audit_log(audit_log)
    end

    def rejected(audit_log)
      sync_audit_log(audit_log)
    end

    protected
    def sync_audit_log(audit_log)
      verify.audit_log_id = audit_log.id
      verify.audit_log_result = audit_log.result
      verify.save!
    end

  end
end
