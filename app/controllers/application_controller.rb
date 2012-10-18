# encoding: UTF-8
class ApplicationController < ActionController::Base

  protect_from_forgery
  #before_filter :authenticate_user!

  before_filter :set_locale

  unless Rails.application.config.consider_all_requests_local
    rescue_from Exception, with: :render_500
    rescue_from ActionController::RoutingError, with: :render_404
    rescue_from ActionController::UnknownController, with: :render_404
    rescue_from ActionController::UnknownAction, with: :render_404
    rescue_from ActiveRecord::RecordNotFound, with: :render_404
  end

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  private

  def check_and_create_albums
    @user = current_user
    @albums = @user.albums
    if @albums.blank?
       @albums.create!([{:user_id => @user.id, :name => "酒"},
                        {:user_id => @user.id, :name => "酒庄"},
                        {:user_id => @user.id, :name => "其他"},])
    end
    @album_id = params[:album_id] ||  @albums.first.id
  end  
  # 主要为了在User Controller 判断是否为当前用户
  def is_login_user?(user)
    if user_signed_in?
      user == current_user
    else
      false
    end
  end

  def store_location
    session[:return_to] = request.referer
  end

  def clear_stored_location
    session[:return_to] = nil
  end

  def redirect_back_or_root_url
    redirect_to(session[:return_to] || root_url)
    clear_stored_location
  end
  
  def devise_return_location
    url = session[:return_to]
    clear_stored_location
    return url || home_index_path  
  end

  def mine_equal_current_user?(user)
    if current_user
      return user.id == current_user.id ? true : false
    else
      return false
    end
  end

  def get_current_user
    @user = current_user
  end

  def after_sign_in_path_for(resource)
    if current_user #跳过admin,因为后台登陆只有current_admin_user 没有current_user
      if current_user.sign_in_count == 1
        return after_first_signins_path
      else
        return request.env['omniauth.origin'] || devise_return_location
      end
    end

  end

  def render_404(exception)
    #@not_found_path = exception.message
    respond_to do |format|
      format.html { render template: 'errors/error_404', layout: 'layouts/application', status: 404 }
      format.all  { render nothing: true, status: 404 }
    end
  end

   def render_500(exception)
     ExceptionNotifier::Notifier
     .exception_notification(request.env, exception)
     .deliver
     @error = exception
     respond_to do |format|
       format.html { render template: 'errors/error_500', layout: 'layouts/application', status: 500 }
       format.all  { render nothing: true, status: 500}
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

  # 关注某支酒
  def follow_one_wine(wine_detail_id)
    wine_detail = Wines::Detail.find(wine_detail_id)
    follow = current_user.following_resource(wine_detail)
  end
  #关注某个酒庄
  def follow_one_winery(winery_id)
    winery = Winery.find(winery_id)
    follow = current_user.following_resource(winery)
  end

  # 关注某个人
  def follow_one_user(user_id)
    current_user.follow_user(user_id)
  end
  
  #获取未读状态的私信和通知
  def get_unread_count
    @unread_receipts_count = current_user.receipts.
                            not_trash.
                            unread.
                            joins(:notification).
                            where('notifications.type' => SystemMessage.to_s).
                            size
    @unread_messages_count = Conversation.unread(current_user).count
  end
end
