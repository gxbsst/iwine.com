# encoding: utf-8

class VerifyForm

  VERIFY_PHOTO_PATH = File.join(Rails.root, "app/assets","verify_files")

  include Virtus
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attribute :identify_card, String
  attribute :description, String
  attribute :identify_photo
  attribute :vocation_photo
  attribute :verify_type
  attribute :real_name, String
  attribute :username, String
  attribute :phone_number, String
  attribute :email, String
  attribute :user_id, Integer
  attribute :agree_term, Integer

  attr_accessor :user, :profile, :verify
  validates :identify_card, :presence => {:message => "请输入您的身份证号码"}
  validates :description, :presence => {:message => "请输入认证说明"}
  validates :phone_number, :presence => {:message => "请输入您的手机号码"}
  validates :real_name, :presence => {:message => "请输入您的真实姓名"}
  validates :identify_card, :identify_card_format => true
  validates :agree_term, :acceptance => true, :on => :create
  validates :vocation_photo, :identify_photo, :presence => {:message => "请上传认证照片"}, :on => :create

  def self.init(user)

    verify = user.verify || user.build_verify
    new(:verify => verify, :user => user)
  end

  def to_param  # overridden
    self.verify.slug
  end

  def to_model
    self.verify
  end

  def identify_card
    @identify_card ||= verify.identify_card
  end

  def description
    @description ||= verify.description
  end

  def email
    @email ||= user.email
  end

  def user_id
    @user_id ||= user.id
  end

  def profile
    @profile ||= user.profile
  end

  def real_name
   @real_name ||= profile.real_name
  end

  def username
    @username ||= user.username
  end

  def phone_number
    @phone_number ||= profile.phone_number
  end

  # Forms are never themselves persisted
  def persisted?
    false
  end

  def save
    if valid?
      persist!
      true
    else
      false
    end
  end

  def update(params)
    params.each {|k, v| instance_variable_set("@#{k}", v) }
    save
    verify.initial #stat machine
  end

  def new_record?
    verify.nil? || verify.new_record?
  end

  private

  def persist!
    if new_record?
      @verify = Verify.create!(verify_params)
      profile.update_attributes!(profile_params)
    else
      verify.update_attributes!(verify_params)
      profile.update_attributes!(profile_params)
    end
  end

  def verify_params
    {
      identify_card: identify_card,
      description: description,
      user_id: user_id,
      identify_photo: identify_photo,
      vocation_photo: vocation_photo,
      agree_term: agree_term,
      verify_type: Verify::VERIFY_TYPE_PERSONAL # TODO, 现在默认是个人， 以后还要添加公司
    }
  end

  def profile_params
    {
      real_name: real_name,
      phone_number: phone_number
    }
  end

end
