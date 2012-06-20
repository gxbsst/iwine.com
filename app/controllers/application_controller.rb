# encoding: UTF-8
class ApplicationController < ActionController::Base
  include ThemesForRails::ActionController
  theme "waterfall"
  # layout "waterfall"
  # layout  proc { |controller|
  #   #span_950 = ["static", "wines"]
  #   # span_860 = ["settings"]
  #   if params[:controller] == "static" && params[:action] == "index"
  #    "waterfall"
  #   elsif params[:controller] == "settings"
  #     "span_860"
  #   else
  #     "span_950"
  #   end
  # }
  # theme "waterfall"
  # default :theme => "waterfall"

  #protect_from_forgery
  #before_filter :authenticate_user!

  before_filter :set_locale


  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  private

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
        return start_user_path(current_user)
      else
        return request.env['omniauth.origin'] || devise_return_location
      end
    end
  end
end
