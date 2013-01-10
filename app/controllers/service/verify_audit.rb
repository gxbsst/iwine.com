module Service
  # encoding: utf-8
  class VerifyAudit
    attr_reader :auditor, :user, :audit_log

    ACCEPTED = 2
    REJECTED = 1

    class << self
      def rejected(auditor, user, options = {})
        user.accepted(build_audit_log(auditor, user, REJECTED,  options))
        Service::MailerService::Mailer.deliver(UserMailer, :verify_rejected, user)
      end

      def accepted(auditor, user, options = {})
        user.accepted(build_audit_log(auditor, user, ACCEPTED,  options))
        Service::MailerService::Mailer.deliver(UserMailer, :verify_accepted, user)
      end

      protected

      def build_audit_log(auditor, auditable, result, options)
        AuditLog.create(:owner_type => OWNER_TYPE_USER,
                        :business_id => auditable.id,
                        :created_by => auditor.id,
                        :result => result,
                        :comment => options[:comment]
        )
      end

    end

  end
end
