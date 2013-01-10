# encoding: utf-8
module VerifiesHelper
  def verify_forms_path(verify)
    verifies_path(verify)
  end

  def audit_status
    return "未审核" unless current_user.audit?
    if current_user.verified?
      "认证审核通过"
    else
      "认证审核未通过"
    end
  end

  def audit_note
    current_user.audit_log_comment  unless current_user.verified?
  end
end
