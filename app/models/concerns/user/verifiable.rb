class User
  module Verifiable
    extend ActiveSupport::Concern

    ACCEPTED = 2
    REJECTED = 1

    included do
      has_one :verify, dependent: :destroy
    end

    def apply_verify?
     !verify.nil?
    end

    def verified?
      #audit? && verify.audit_log_result == ACCEPTED
      audit? && verify.accepted?
    end

    def audit?
      apply_verify? && !verify.inaudit?
      #!verify.audit_log_result.nil?
    end

    def audit_log
      ::AuditLog.where(:owner_type => OWNER_TYPE_USER, :business_id => id).last
    end

    def audit_log_comment
      return nil unless audit?
      audit_log.comment
    end

    def accepted(audit_log)
      verify.accepted
      sync_audit_log(audit_log)
    end

    def rejected(audit_log)
      verify.injected
      sync_audit_log(audit_log)
    end

    def verify_desc
      verify.description
    end

    protected
    def sync_audit_log(audit_log)
      verify.audit_log_id = audit_log.id
      verify.audit_log_result = audit_log.result
      verify.save!
    end

  end
end
