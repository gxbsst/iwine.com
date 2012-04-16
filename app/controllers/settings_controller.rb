# encoding: utf-8
class SettingsController < ApplicationController

  before_filter :authenticate_user!

  def basic
    @title = "基本设置"

    @profile = current_user.profile
    @profile ||= Users::Profile.new

    if request.put?
      @user = current_user
      @profile = current_user.profile

      ## 处理配置信息
      set_config 

      ## 处理所在地信息
      set_living_city_id

      if @user.update_attribute(:username, params[:users_profile][:username]) &&  @profile.update_attributes(params[:users_profile])
        notice_stickie("更新成功.")
      end
      # redirect_to :action => 'basic'
    end
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

  def syncs
    @sns_servers = SNS_SERVERS
    @avaliable_sns = current_user.available_sns

  end

  def sync
    sns_class_name = params[:sns_name].capitalize
    oauth_module = eval( "OauthChina::#{sns_class_name}" )
    client = oauth_module.new
    authorize_url = client.authorize_url
    Rails.cache.write(build_oauth_token_key(client.name, client.oauth_token), client.dump)
    redirect_to authorize_url
  end

  def callback
    sns_class_name = params[:type].capitalize
    oauth_module = eval( "OauthChina::#{sns_class_name}" )
    client = oauth_module.load(Rails.cache.read(build_oauth_token_key(params[:type], params[:oauth_token])))
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

    redirect_to :action => 'syncs'
  end

  def account

  end

  def avatar
    
    @title = "设置头像"

    # 保存图片
    if request.put?
      if save_avatar 
        notice_stickie t("save_successed")  
      end
      redirect_to :action => :avatar      
      
    end

    # 裁剪图片
    if request.post?
      if params[:user][:crop_x].present?
        crop_avatar
        notice_stickie t("save_successed")  
      end
      
      redirect_to :action => :basic      
      
    end

  end

  private

  def set_config
    params[:config].each {|k,v| @profile.config[k] = v }
  end

  def set_living_city_id
    regions = params[:region]

    regions.reject!{ |k,v| v.blank? }
    return true if regions.blank?

    regions.keys.each_with_index do |key, index|
      if index == regions.length - 1
        params[:users_profile][:living_city] = regions[key]
      end
    end
  end

  def build_oauth_token_key(name, oauth_token)
    [name, oauth_token].join("_")
  end

  ## 保存图片
  def save_avatar
    current_user.avatar = params[:user][:avatar]
    current_user.save
  end

  # ## 更新图片
  def crop_avatar
     current_user.update_attributes(params[:user])
  end

end
