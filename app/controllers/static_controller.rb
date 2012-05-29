# encoding: UTF-8
class StaticController < ApplicationController
  
  def home
    @title =  t("nav.home") 
  end
  def index
    @title =  t("nav.root")
  end
  
  def private
       @title =  t("nav.private")
  end
  
  def help
    @title = t("nav.help")
  end
  
  def site_map
    @title = t("nav.site_map")
  end
  
  def about_us
   @title =  t("nav.about_us")
  end

  def contact_us
    @title = t("nav.contact_us")
  end

  def feedback
    @title = t("nav.feedback")
  end
end
