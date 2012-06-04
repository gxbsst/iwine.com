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

  def get_current_user
    @user = current_user
  end

  def after_sign_in_path_for(resource)
    if current_user.sign_in_count == 1
      return start_user_path(current_user)
    else
      return request.env['omniauth.origin'] || stored_location_for(resource) || home_index_path
    end
  end
end
