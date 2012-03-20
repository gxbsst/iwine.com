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
    @title = "修改密码"
    @user = current_user
    if request.put?
      @user = User.find(current_user.id)
      if @user.update_attributes(params[:user])
        # Sign in the user by passing validation in case his password changed
        sign_in @user, :bypass => true
        notice_stickie t("update_success")
        # redirect_to root_path
      else
        error_stickie t("update_failed")
        redirect_to :action => "update_password"
      end
    end

  end

  def privacy
    @title = "隐私设置"
    @profile = current_user.profile
    
    if request.put?
      set_config
      if @profile.save
        notice_stickie t("update_success.")
      end
    end
    
  end

  def invite

  end

  def sync

  end

  def account
    Hash
  end

  def avatar
    @title = "设置头像"
    @photos = current_user.photos
    #@avatar = current_user.avatar
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

end
