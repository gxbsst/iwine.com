class Users::Oauth < ActiveRecord::Base
  set_table_name "user_oauths"
  attr_accessor :sns_info
  attr_accessible :sns_user_id, :sns_name, :provider_user_id, :access_token, :user_id, :setting_type,
    :openid, :openkey, :refresh_token, :session_key, :activation
  belongs_to :user
  scope :oauth_record, ->(sns_name){ where(["sns_name = ?", sns_name])}
  scope :oauth_login, where("setting_type = ? ", APP_DATA['user_oauths']['setting_type']['login'])
  scope :oauth_binding, where("setting_type = ? ", APP_DATA['user_oauths']['setting_type']['binding'])
  scope :login_provider, lambda { |provider|  where(["sns_name = ? ", provider])}

  after_save :sync_friends

  def sync_friends
    UserSnsFriend::sync_one(user, self)
  end

  def tokens
    { :access_token => access_token, :access_token_secret => refresh_token }
  end

  def qq_tokens
    {:access_token => access_token, :openid => openid}
  end

  # Oauth Login
  def self.from_omniauth(auth, provider, uid)
    #查找oauth_user, 如果没有新的纪录就在内存中新建一个oauth_user
    oauth_user = oauth_login.where(:sns_user_id => uid, :sns_name => provider).
                            first_or_initialize(:provider_user_id => uid,
                                                :access_token => auth.credentials.token)
    # TODO
    # 1. 先检查user_oauth表有没有记录
    # 如果没有，则在user是表创建记录， 然后在oauth表创建记录
    # 绑定帐号
  end
  
  #仅用于绑定不用于登陆
  #创建oauth_user或者刷新access_token
  def self.build_binding_oauth(user, oauth_options = {}, qq_options = {})
    oauth_user = user.oauths.oauth_binding.where(:sns_name => oauth_options[:sns_name]).first_or_initialize
    oauth_user.access_token = oauth_options[:access_token]
    #绑定第二个账户时覆盖掉第一个账户的id。
    oauth_user.provider_user_id = oauth_options[:uid]
    oauth_user.sns_user_id = oauth_options[:uid]
    oauth_user.refresh_token = oauth_options[:refresh_token]
    #新增或者更新openid 和 openkey
    oauth_user.openid = qq_options[:openid]
    oauth_user.openkey = qq_options[:openkey]
    oauth_user.save
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
  
  #此方法不验证login 时oauth_user 的唯一性。
  #如果是第三方登陆操作同时创建两个user_oauth记录
  def self.build_oauth(user, attributes)
    #创建或者刷新绑定用户
    oauth_binding_user = user.oauths.oauth_binding.
        where(:sns_name => attributes["sns_name"]).
        first_or_initialize(:sns_user_id => attributes["sns_user_id"], :provider_user_id => attributes["provider_user_id"])
    oauth_binding_user.access_token = attributes['access_token']
    oauth_binding_user.save

    #创建登陆用户
    oauth_login_user = user.oauths.oauth_login.
        where(:sns_name => attributes["sns_name"]).first_or_initialize
    oauth_login_user.setting_type = APP_DATA['user_oauths']['setting_type']['login']
    oauth_login_user.provider_user_id = attributes["provider_user_id"]
    oauth_login_user.sns_user_id = attributes["sns_user_id"]
    oauth_login_user.access_token = attributes['access_token']
    oauth_login_user.save
  end

  def update_token(access_token)
    self.update_attribute(:access_token, access_token)
  end
end
