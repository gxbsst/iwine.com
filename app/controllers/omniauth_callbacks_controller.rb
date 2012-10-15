class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def all

    if current_user #绑定操作
      oauth_user = Users::Oauth.build_binding_oauth(current_user, request.env["omniauth.auth"])
      oauth_user.save
      if oauth_user.new_record?
        oauth_user.save
        redirect_to setting_sns_friends_path
      else
        Users::Oauth.update_token(request.env["omniauth.auth"])
        notice_stickie t('notice.oauth.update_oauth')
        redirect_to sync_friends_path(:sns_name => 'weibo', :success => true) #设置success控制sync页面得javascript
      end
    else #登陆操作
      oauth_user = Users::Oauth.from_omniauth(request.env["omniauth.auth"])
      if oauth_user.new_record?
        session["devise.user_attributes"] = oauth_user.attributes
        redirect_to new_oauth_login_path
      else
        notice_stickie t("notice.login_success")
        Users::Oauth.update_token(request.env["omniauth.auth"])
        @user = User.find(oauth_user.user_id)
        sign_in_and_redirect @user
      end
    end
  end
  
  #alias_method :twitter, :all
  alias_method :qq_connect, :all
  alias_method :weibo, :all
  alias_method :renren, :all
end
