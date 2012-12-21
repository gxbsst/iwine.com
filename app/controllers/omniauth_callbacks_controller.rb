class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def all
    request_auth = request.env["omniauth.auth"]
    provider = request_auth.provider == 'tqq2' ? 'qq' : request_auth.provider
    uid = provider == "qq" ? request_auth.credentials.openid : request_auth.uid
    qq_options = provider == "qq" ? {:openid =>request_auth.credentials.openid, :openkey => request_auth.credentials.openkey} : {}

    if current_user #绑定操作
      Users::Oauth.build_binding_oauth(current_user, {
        :sns_name => provider,
        :access_token => request_auth.credentials.token,
        :uid => uid
        }, qq_options)
      notice_stickie t('notice.oauth.update_oauth')
      redirect_to sync_friends_path(:sns_name => provider, :success => true) #设置success控制sync页面得javascript
    else #登陆操作
      oauth_user = Users::Oauth.from_omniauth(request_auth, provider, uid)
      if oauth_user.new_record?
        session["devise.user_attributes"] = oauth_user.attributes
        redirect_to new_oauth_login_path
      else
        notice_stickie t("notice.login_success")
        oauth_user.update_token(request_auth.credentials.token)
        @user = User.find(oauth_user.user_id)
        sign_in_and_redirect @user
      end
    end
  end

  #alias_method :twitter, :all
  alias_method :qq_connect, :all
  alias_method :weibo, :all
  alias_method :renren, :all
  alias_method :tqq2, :all
end
