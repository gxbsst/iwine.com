# encoding: utf-8
class Verify < ActiveRecord::Base

  belongs_to :user
  attr_accessible :description, :image, :indentify_card, :trade_type, :varify_type
  attr_protected :audit_log_id, :audit_log_result

  mount_uploader :image, VerifyUploader

  extend FriendlyId

  friendly_id :uuid, :use => [:slugged]

  def uuid
    SecureRandom.uuid
  end


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
