module Service
  # encoding: utf-8
  class VerifyAudit
    attr_reader :auditor, :user, :audit_log

    def self.execute(auditor, user)
      new(auditor, verify).run
    end

    def initialize(auditor, verify)
      @auditor = auditor
      @verify = verify
    end

    def run
      # verify.audit
      # audit log
      # update user
      # update verify
      # email
    end

    def rejected
    end

    def accepted
      User.transaction do
        AuditLog.create
        user.accept
        # send email
      end
    end
  end
end
