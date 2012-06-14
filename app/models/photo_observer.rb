class PhotoObserver < ActiveRecord::Observer

  def after_update model
    if model.is_audit_status_changed && model.audit_status != 0
      audit_log = AuditLog.create(
        :owner_type => OWNER_TYPE_PHOTO,
        :business_id => model.id,
        :result => model.audit_status
      )
      #使用 update_column 跳过callback
      model.update_column("audit_id", audit_log.id)
    end
  end
end
