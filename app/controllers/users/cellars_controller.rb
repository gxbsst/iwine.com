# encoding: UTF-8
class Users::CellarsController < ApplicationController
  before_filter :get_user
  before_filter :get_cellar
  def index
    @user = User.find(params[:user_id])
    @cellar_items = @user.cellar.items.includes(:wine_cellar, {:wine_detail => [:covers, :wine]}).page params[:page] || 1
    @cellar_items = @cellar_items.where("private_type = 0") if !current_user || (current_user && current_user.id != @user.id)
  end
  
  def edit
    
  end
  
  def show
    if params[:wine_name]
      @cellar_items = @cellar.items.includes(:wine_cellar, {:wine_detail => [:covers, :wine]}).joins(:wine_detail => :wine).where("(wines.name_en like ? or wines.name_zh like ? ) and private_type = 0", "%#{params[:wine_name]}%", "%#{params[:wine_name]}%").page params[:page] || 1
    else
      @cellar_items = @cellar.items.includes(:wine_cellar, {:wine_detail => [:covers, :wine]}).where("private_type = 0").page params[:page] || 1
    end
  end

  private
  def get_cellar
    @cellar = @user.cellar
  end

  def get_user
    @user = User.find(params[:user_id])
  end
end