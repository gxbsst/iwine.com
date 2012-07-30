class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def all
    oauth_user = Users::Oauth.from_omniauth(request.env["omniauth.auth"])
    if oauth_user.new_record?
      session["devise.user_attributes"] = oauth_user.attributes
      redirect_to new_oauth_login_path
    else
      Users::Oauth.update_token(request.env["omniauth.auth"]) #刷新access_token
      notice_stickie t("notice.login_success")
      @user = User.find(oauth_user.user_id)
      sign_in_and_redirect @user
    end
  end
  
  #alias_method :twitter, :all
  alias_method :qq_connect, :all
  alias_method :weibo, :all
  alias_method :renren, :all
end
