# encoding: utf-8
class Verify < ActiveRecord::Base

  VERIFY_TYPE_PERSONAL = 1
  VERIFY_TYPE_COMPANY = 2

  belongs_to :user
  attr_accessible :description, :vocation_photo, :identify_card, :trade_type, :identify_photo, :agree_term
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

  state_machine initial: :inaudit do
    event :accepted do
      transition :inaudit => :accepted
    end

    event :rejected do
      transition :inaudit => :rejected
    end

    event :initial do
      transition [:rejected, :inaudit] => :inaudit
    end

    #before_transition :inaudit => :accepted do |order|
    #  # process payment ...
    #
    #end
  end

end
