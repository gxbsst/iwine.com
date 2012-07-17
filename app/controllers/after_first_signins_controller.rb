#encoding: utf-8
class AfterFirstSigninsController < ApplicationController
  include Wicked::Wizard

  steps :upload_avatar, :update_info, :follow_users, :follow_wines, :follow_wineries

  def show
  	@user = current_user
    case step
    when :follow_users
      @recommend_users = User.no_self_recommends(20, current_user.id)
    when :follow_wines
      @hot_wines = Wines::Detail.hot_wines(9)
    when :follow_wineries
      @hot_wineries = Winery.hot_wineries(9)
    end
  	render_wizard
  end

  def update
    @user = current_user
    case step 
    when :update_info
      update_user_info
    when :follow_users
      follow_user
    when :follow_wines
      follow_wine
    when :follow_wineries
      follow_winery
    end
    render_wizard(@user)
  end

  def upload_avatar
    @title = "设置头像"
  	@user = current_user
    update_avatar
  end
  
  private

  def update_user_info
    if request.put?
      @title = "账号设置"
      @user = current_user
      @user.update_attributes(params[:user])
      @user.profile.update_attributes(params[:user][:profile_attributes])
    end
  end

  def update_avatar
    #提交图片
    if request.put?
      if params[:user].present?
        unless save_avatar
          notice_stickie t("notice.upload_photo_failure")
        end
      else
        notice_stickie t("notice.photo.please_upload")
      end
      # redirect_to upload_avatar_after_first_signins_path
    end

    #建材图片
    if request.post?
      if params[:user][:crop_x].present?
        crop_avatar
      end
      redirect_to next_wizard_path
    end
  end

  def follow_user   
    if request.put?
      # follow users
      if params[:user_ids].present?
        params[:user_ids].each do |user_id|
          follow_one_user(user_id)
        end
      end # end users

      # 填充用户的Home内容
      current_user.init_events_from_followings
    end # end post
  end

  def follow_wine
    if request.put?
      # follow wines
      if params[:wine_detail_ids].present?
        params[:wine_detail_ids].each do |wine_detail_id|
          follow_one_wine(wine_detail_id)
        end
      end # end wines
      current_user.init_events_from_followings
    end
  end

  def follow_winery
    if request.put?
      if params[:winery_ids].present?
        params[:winery_ids].each do |id|
          follow_one_winery(id)
        end
      end
      current_user.init_events_from_followings
    end
  end

  #完成所有步骤后进入个人首页
  def redirect_to_finish_wizard
    redirect_to home_index_path
  end
end
