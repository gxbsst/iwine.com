# encoding: utf-8
class SettingsController < ApplicationController

  before_filter :authenticate_user!

  def basic
    @title = "基本设置"
    @user = User.includes(:profile).find(current_user.id)
    @user.profile ||= @user.build_profile
    @user.avatar ||= @user.build_avatar
    ## TODO 
    # update ...
    # if request.put?
    #   @user = User.new(params[:user])
    #   notice_stickie("更新成功成功.")
    #   # redirect_to :action => 'basic'
    # end
  end

  def update_password
    @user = current_user
    
    if request.put?
      @user = User.find(current_user.id)
      if @user.update_attributes(params[:user])
        # Sign in the user by passing validation in case his password changed
        sign_in @user, :bypass => true
        # redirect_to root_path
      else
        redirect_to :action => "update_password"
      end
    end
  end

  def privacy

  end

  def invite

  end

  def sync
    @oauth_list = [ :sina ]
    @oauth_list = Users::Oauth.all :conditions => { :user_id => current_user.id }

    c = current_user.oauth_client :sina
  end

  def account

  end

  def avatar
    @title = "设置头像"
    @photos = current_user.photos
    @photo = Photo.new

    if request.post?
      @photo.image = params[:photo][:image]
      @photo.owner_type = OWNER_TYPE_USER
      @photo.business_id= current_user.id
      @photo.save
    end

    if request.put?
      @photo = Photo.find(params[:id])
      @photo.crop_x = params[:photo][:crop_x]
      @photo.crop_y = params[:photo][:crop_y]
      @photo.crop_w = params[:photo][:crop_w]
      @photo.crop_h = params[:photo][:crop_h]

      @photo.save
      redirect_to '/users/avatar'
      return
    end
  end

  def sync 
    client = OauthChina::Sina.new
    authorize_url = client.authorize_url
    Rails.cache.write(build_oauth_token_key(client.name, client.oauth_token), client.dump)
    redirect_to authorize_url
  end

  def callback
    client = OauthChina::Sina.load(Rails.cache.read(build_oauth_token_key(params[:type], params[:oauth_token])))
    client.authorize(:oauth_verifier => params[:oauth_verifier])
    results = client.dump

    if results[:access_token] && results[:access_token_secret]
      flash[:notice] = "done"
    else
      flash[:notice] = "fail"
    end

    user_oauth = Users::Oauth.new 
    user_oauth.user_id = current_user.id
    user_oauth.access_token = results[:access_token]
    user_oauth.sns_name = client.name.to_s
    user_oauth.sns_user_id = client.me["id"]
    user_oauth.refresh_token = results[:access_token_secret]
    user_oauth.save

  end

  def build_oauth_token_key(name, oauth_token)
    [name, oauth_token].join("_")
  end

end
