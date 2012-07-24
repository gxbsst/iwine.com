class Users::Oauth < ActiveRecord::Base

  attr_accessor :sns_info

  include Users::UserSupport

  belongs_to :user
  
  scope :oauth_record, ->(sns_name){ where(["sns_name = ?", sns_name])}
  
  def tokens
    { :access_token => access_token, :access_token_secret => refresh_token }
  end

  # Oauth Login
  def self.from_omniauth(auth)
    provider_info = auth.slice(:provider, :uid) 
    where(:sns_user_id => provider_info[:uid], 
          :sns_name => provider_info[:provider]).first_or_create do |user|
      user.sns_name = auth.provider
      user.sns_user_id = auth.uid
      user.user_id = 1
      #user.username = auth.info.nickname
    end
    # TODO
    # 1. 先检查user_oauth表有没有记录
    # 如果没有，则在user是表创建记录， 然后在oauth表创建记录
    # 绑定帐号
  end

  def self.new_with_session(params, session)
    if session["devise.user_attributes"]
      new(session["devise.user_attributes"], without_protection: true) do |user|
        user.attributes = params
        user.valid?
      end
    else
      super
    end
  end

  def password_required?
    super && provider.blank?
  end

end
