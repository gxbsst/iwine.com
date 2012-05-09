# encoding: UTF-8
class Users::CellarsController < ApplicationController

  def index
    @user = User.find(params[:user_id])
    @cellar_items = @user.cellar.items.includes(:wine_cellar, {:wine_detail => [:covers, :wine]}).page params[:page] || 1
    @cellar_items = @cellar_items.where("private_type = 0") if !current_user || (current_user && current_user.id != @user.id)
  end
  
  def edit
    
  end
  
  def show

  end
end