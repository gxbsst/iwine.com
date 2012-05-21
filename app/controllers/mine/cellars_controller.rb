# encoding: UTF-8

class Mine::CellarsController < ApplicationController
 before_filter :require_user
 before_filter :get_cellar
 before_filter :get_mine

  def show
     if params[:wine_name]
       @cellar_items = @cellar.items.includes(:wine_cellar, {:wine_detail => [:covers, :wine]}).joins(:wine_detail => :wine).where("wines.name_en like ? or wines.name_zh like ? ", "%#{params[:wine_name]}%", "%#{params[:wine_name]}%").page params[:page] || 1
     else
       @cellar_items = @cellar.items.includes(:wine_cellar, {:wine_detail => [:covers, :wine]}).page params[:page] || 1
     end
  end

  private 
  def get_cellar
    @cellar = current_user.cellar
  end

end
