# encoding: UTF-8
class ApplicationController < ActionController::Base
  # layout "waterfall"
  layout  proc { |controller|
    #span_950 = ["static", "wines"]
    # span_860 = ["settings"]
    if params[:controller] == "static" && params[:action] == "index"
     "waterfall"
    elsif params[:controller] == "settings"
      "span_860"
    else
      "span_950"
    end
  }


  #protect_from_forgery
  #before_filter :authenticate_user!

  before_filter :set_locale

  def index

  end

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  private
   def require_user
     redirect_to root_url, :notice => "登录后才能执行此操作" unless current_user
   end

   def get_mine
     @user = current_user
   end
end
