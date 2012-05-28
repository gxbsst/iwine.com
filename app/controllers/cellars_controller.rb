# encoding: UTF-8
class CellarsController < ApplicationController

  before_filter :get_user
  before_filter :get_cellar

  def show
    if params[:wine_name]
      @cellar_items = @cellar.items.includes(:wine_cellar, {:wine_detail => [:covers, :wine]}).joins(:wine_detail => :wine).where("wines.name_en like ? or wines.name_zh like ? ", "%#{params[:wine_name]}%", "%#{params[:wine_name]}%").page params[:page] || 1
    else
      @cellar_items = @cellar.items.includes(:wine_cellar, {:wine_detail => [:covers, :wine]}).page params[:page] || 1
    end
  end

  private 

  def get_cellar
    @cellar = @user.cellar
  end

  def get_user
    @user = User.find(params[:id])
  end

end
