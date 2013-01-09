class User
  module Verifiable
    extend ActiveSupport::Concern
    included do
      has_one :verify, dependent: :destroy
    end

    def verified?
      # verify audit log id not null && result == maybe (2)
    end

    def accepted(audit_log)
      sync_audit_log(audit_log)
      #self.update_attibutes!(veriy_type)
    end

    def rejected(audit_log)
      sync_audit_log(audit_log)
    end

    protected
    def sync_audit_log(audit_log)
      verfy.update_attibutes!(audit_log_id: audit_log.id,
                              audit_log_result: audit_log.result)
    end

  end
end
