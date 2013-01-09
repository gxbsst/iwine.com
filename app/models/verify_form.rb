class VerifyForm

  include Virtus
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attribute :indentify_card, String
  attribute :description, String
  attribute :image
  attribute :verify_type, String
  attribute :real_name, String
  attribute :phone_number, String
  attribute :email, String
  attribute :user_id, Integer

  attr_accessor :user, :profile, :verify
  validates :indentify_card, :presence => true

  def self.init(user)
    verify = user.verify.where(user_id: user.id).first_or_initialize
    new(:verify => verify, :user => user)
  end

  #def to_param  # overridden
    #self.verify
  #end

  def indentify_card
    @indentify_card ||= verify.indentify_card
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
  end

  def new_record?
    verify && verify.new_record?
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
      indentify_card: indentify_card,
      description: description,
      user_id: user_id,
      image: image
    }
  end

  def profile_params
    {
      real_name: real_name,
      phone_number: phone_number
    }
  end

end
