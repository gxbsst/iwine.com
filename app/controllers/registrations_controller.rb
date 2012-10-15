#encoding: utf-8
class RegistrationsController < Devise::RegistrationsController
  def create
  	if params[:oauth]
  	  @binding_user = User.new(params[:user])
  	  #在user save 前，设置confirmed_at 激活用户。
  	  @binding_user.confirmed_at = DateTime.now
  	  if @binding_user.save
  	    Users::Oauth.build_oauth(@binding_user, session["devise.user_attributes"]) #同时创建oauth_user
  	    sign_in(:user, @binding_user) #登陆用户
  	  	redirect_to after_first_signins_path
  	  else
  	  	render :template => "oauth_logins/new.html.erb"
  	  end
  	else
  	  super
    end
  end

  protected

  def after_sign_up_path_for(resource)
  	root_path
  end
  
  def after_inactive_sign_up_path_for(resource)
    "/users/register_success?email=#{resource.email}"
  end
end

