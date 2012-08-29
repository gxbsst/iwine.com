#encoding: utf-8
class SessionsController < Devise::SessionsController

  def create
  	if params[:oauth]
  		#处理用户第三方绑定登陆
  	  if !user_signed_in?
        @error = true
  	  	render :template => "oauth_logins/new.html.erb"
  	  else
  	  	oauth_attributes = session['devise.user_attributes']
  	  	super
  	  	Users::Oauth.build_oauth(current_user, oauth_attributes)
  	  end 
  	else
  	  super
  	end
  end

end