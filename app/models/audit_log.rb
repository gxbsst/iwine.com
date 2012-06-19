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

  after_create :set_photo_audit_migrate_status, :if => lambda { |log| log.owner_type.to_i == OWNER_TYPE_PHOTO }

  def logable
    case owner_type.to_i
    when OWNER_TYPE_PHOTO
      Photo.find(business_id)
    when OWNER_TYPE_WINE_REGISTER
      # TODO ....
    when OWNER_TYPE_WINERY
      # TODO ....
    when OWNER_TYPE_WINE
      # TODO ....
    when OWNER_TYPE_USER
      # TODO ....
    end
  end

  #处理 audit migrate status
  def set_photo_audit_migrate_status
      audit_logs = AuditLog.where(:owner_type => OWNER_TYPE_PHOTO , :business_id => business_id ).order("id DESC").limit(2)
      audit_status_value = audit_logs.collect{|l| l.result.to_i}
      # 0 是提交 1 是通过审核 2 是驳回， 参考 data.yml
      # @audit_status_value 
      #  [0,1]  提交 ＝》通过审核
      #  [0,2]  提交 ＝》驳回
      #  [1,2] 通过审核 => 驳回
      #  [2,1]  驳回 ＝》通过审核
      #  [2,0] 不存在的状态
      # Rails.logger.info("..audit_status_value........#{audit_status_value}........")
      Rails.logger.info("================#{audit_status_value}........" )
      case audit_status_value
      when [APP_DATA["audit_log"]["status"]["approved"].to_i] # 第一次审核
        @audit_migrate_status = 1
      when [APP_DATA["audit_log"]["status"]["approved"].to_i, APP_DATA["audit_log"]["status"]["submitted"].to_i]
        @audit_migrate_status = 1 # [1, 0]  提交 ＝》通过审核
      when [APP_DATA["audit_log"]["status"]["rejected"].to_i, APP_DATA["audit_log"]["status"]["submitted"].to_i]
        @audit_migrate_status = 2 # [2,0]  提交 ＝》驳回
      when [APP_DATA["audit_log"]["status"]["rejected"], APP_DATA["audit_log"]["status"]["approved"]]  
        @audit_migrate_status = 3  # [2,1] 通过审核 => 驳回
      when [APP_DATA["audit_log"]["status"]["approved"], APP_DATA["audit_log"]["status"]["rejected"]]   
        @audit_migrate_status = 4 # [1,2]  驳回 ＝》通过审核
      end 
      Rails.logger.info("================#{@audit_migrate_status}........" )
   end 

   ## 通过audit_migrate_status 判断图片数量是否增加
   def counts_should_increment?
    
    if @audit_migrate_status == 1 || @audit_migrate_status == 4  #[1,0]  提交 ＝》通过审核
      true
    else
      false
    end
   end

   ## 通过audit_migrate_status 判断图片数量是否减少
   def counts_should_decrement?
    if @audit_migrate_status == 3  #[2,1]  通过审核 => 驳回
      true
    else
      false
    end
   end
end
