# encoding: utf-8
class Verify < ActiveRecord::Base

  VERIFY_TYPE_PERSONAL = 1
  VERIFY_TYPE_COMPANY = 2

  belongs_to :user
  attr_accessible :description, :vocation_photo, :identify_card, :trade_type, :identify_photo
  attr_protected :audit_log_id, :audit_log_result

  mount_uploader :identify_photo, VerifyUploader::Identify
  mount_uploader :vocation_photo, VerifyUploader::Vocation

  extend FriendlyId

  friendly_id :uuid, :use => [:slugged]

  def uuid
   slug || SecureRandom.uuid
  end

  #def as_json(options = {})
  #  super.merge('image' => image.as_json[:image], 'varify_type' => varify_type.as_json[:varify_type])
  #end

  class VerifyType
    attr_accessor :name, :id

    MAPPING = { 1 => 'personal', 2 => 'company'}

    def self.all;
      MAPPING
    end

    def id
      MAPPING.invert[name]
    end

    def logo;end

  end

  class TradeType
    attr_accessor :name, :id
  end

  class Image
    attr_accessor :url
  end

end
