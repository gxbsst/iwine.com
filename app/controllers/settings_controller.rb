# encoding: utf-8
class SettingsController < ApplicationController

  before_filter :authenticate_user!
  before_filter :get_profile
  
  def basic
    @title = "帐号设置"
    @availabe_sns = current_user.available_sns
    @user = current_user
    # @profile = current_user.profile || current_user.build_profile
    if request.put?
      # @user = current_user
      # @profile = current_user.profile
      ## 处理配置信息
      # set_config
      ## 处理所在地信息
      #
      if current_user.update_attributes(params[:user]) &&
        current_user.profile.update_attributes(params[:user][:profile_attributes])
        
        notice_stickie t("notice.update_success")
        
      end
      redirect_to basic_settings_path
    end
  end

  def update_password
    @title = "修改密码"
    @user = current_user
    if request.put?
      if params[:user][:password].blank?
        error_stickie t("notice.password.reset_password_failure")
        redirect_to update_password_settings_path
        return 
      end
      @user = User.find(current_user.id)
      if @user.update_with_password(params[:user])

        # Sign in the user by passing validation in case his password changed
        sign_in @user, :bypass => true
        notice_stickie t("notice.password.reset_password_success")
        redirect_to basic_settings_path
      else
        error_stickie t("notice.password.reset_password_failure")
        redirect_to update_password_settings_path
      end
    end

  end

  def privacy
    @title = "广播/通知设置"
    @profile = current_user.profile
    # binding.pry
    if request.put?
      set_config
      if @profile.save
        notice_stickie t("notice.update_success")
        redirect_to basic_settings_path
      end
    end

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

    redirect_to syncs_settings_path
  end

  def avatar
    @title = "设置头像"
    # 保存图片
    if request.put?
      if params[:user].present?
        if save_avatar
          notice_stickie t("notice.upload_photo_success")
        else
          notice_stickie t("notice.upload_photo_failure")
        end
      else
        notice_stickie t("notice.photo.please_upload")
      end
      redirect_to avatar_settings_path
    end

    # 裁剪图片
    if request.post?
      if params[:user][:crop_x].present?
        crop_avatar
        notice_stickie t("notice.photo.upload_avatar_success")
      end
      redirect_to basic_settings_path
    end
  end
 
  def update
    @user = current_user
    respond_to do |wants|
      if @user.update_attributes(params[:user])
        notice_stickie "设置成功" 
        wants.html { redirect_to(basic_settings_path) }
        wants.xml  { head :ok }
      else
        wants.html { render :action => :domain }
        wants.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end
  def domain
    @user = current_user
    if request.put?
      respond_to do |wants|
        @user.domain=params[:user][:domain]
        if @user.save
          notice_stickie "设置成功" 
          wants.html { redirect_to(basic_settings_path) }
          wants.xml  { head :ok }
        else
          wants.html { render :action => :domain }
          wants.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  private

  def set_config
    unless params[:config][:share]
      @profile.config.share.wine_cellar = 0
      @profile.config.share.wine_simple_comment = 0
    end
    params[:config].each {|k,v| @profile.config[k] = v }
  end

  def build_oauth_token_key(name, oauth_token)
    [name, oauth_token].join("_")
  end

  def get_profile
    @profile = current_user.profile
  end
end
