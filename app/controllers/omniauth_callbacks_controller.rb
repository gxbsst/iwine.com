class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def all
    user = Users::Oauth.from_omniauth(request.env["omniauth.auth"])
    if user.persisted?
      flash.notice = "Signed in!"
      @user = User.find(user.user_id)
      sign_in_and_redirect @user
    else
      session["devise.user_attributes"] = user.attributes
      redirect_to new_user_registration_url
    end
  end
  #alias_method :twitter, :all
  alias_method :qq_connect, :all
  alias_method :weibo, :all
  alias_method :renren, :all
end
