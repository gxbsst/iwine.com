
class ApplicationController < ActionController::Base
  # layout "waterfall"
  layout  proc { |controller|
    span_950 = ["static", "wines"]
    # span_860 = ["settings"]
    if params[:controller].include? "static"
      "waterfall_950"
    elsif params[:controller].include? "mine"
      "span_950"
    else
      "waterfall"
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

end
