class Users::Oauth < ActiveRecord::Base
  set_table_name "user_oauths"
  attr_accessor :sns_info
  belongs_to :user
  scope :oauth_record, ->(sns_name){ where(["sns_name = ?", sns_name])}
  scope :oauth_login, where("setting_type = ? ", APP_DATA['user_oauths']['setting_type']['login'])
  scope :oauth_binding, where("setting_type = ? ", APP_DATA['user_oauths']['setting_type']['binding'])
  
  def tokens
    { :access_token => access_token, :access_token_secret => refresh_token }
  end

  # Oauth Login
  def self.from_omniauth(auth)
    provider_info = auth.slice(:provider, :uid) 
    #查找oauth_user, 如果没有新的纪录就在内存中新建一个oauth_user
    oauth_user = oauth_login.where(:sns_user_id => provider_info[:uid], 
                                   :sns_name    => provider_info[:provider]).
                            first_or_initialize(:sns_name => auth.provider,
                                                :sns_user_id => auth.uid,
                                                :access_token => auth.credentials.token)
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
  
  def self.build_oauth(user, attributes)
    type = [APP_DATA['user_oauths']['setting_type']['login'], APP_DATA['user_oauths']['setting_type']['binding']]
    type.each do |t|
      oauth_user = where(:sns_user_id => attributes["sns_user_id"], 
                          :sns_name    => attributes["sns_name"],
                          :setting_type => t).first
      unless oauth_user
        oauth_user = Users::Oauth.new(attributes)
        oauth_user.user_id = user.id
        oauth_user.setting_type = t
        oauth_user.save
      end
    end
  end

  def self.update_token(oauth)
    oauth_user = oauth_binding.where(:sns_user_id => oauth.uid,
                                      :sns_name => oauth.provider).first
    if oauth_user
      oauth_user.update_attribute(:access_token, oauth.credentials.token)
    end
  end
end
