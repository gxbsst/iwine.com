# encoding: utf-8
class SettingsController < ApplicationController

  before_filter :authenticate_user!

  def basic
    @title = "帐号设置"

    @profile = current_user.profile || current_user.build_profile

    if request.put?
      @user = current_user
      @profile = current_user.profile

      ## 处理配置信息
      # set_config

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
    @title = "广播/通知设置"
    @profile = current_user.profile
    # binding.pry
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

  ## 保存图片
  def save_avatar
    current_user.avatar = params[:user][:avatar]
    current_user.save
  end

  # ## 更新图片
  def crop_avatar
    current_user.update_attributes(params[:user])
  end

  # 初始化配置信息
  def init_configs

  end

end
