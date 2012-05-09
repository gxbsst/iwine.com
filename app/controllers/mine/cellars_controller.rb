# encoding: UTF-8
class Mine::CellarsController < ApplicationController
 before_filter :get_cellar
 
  def index
    @cellar_items = @cellar.items.includes(:wine_cellar, {:wine_detail => [:covers, :wine]}).page params[:page] || 1
  end
  
  def show
     @cellar_items = @cellar.items.includes(:wine_cellar, {:wine_detail => [:covers, :wine]}).page params[:page] || 1
  end

  def new
    @wine_detail = Wines::Detail.includes( :covers, :photos, :statistic,  { :wine => [:style, :winery]} ).find( params[:wine_detail_id].to_i )
    @wine = @wine_detail.wine
    @cellar_item = Users::WineCellarItem.new
    @cellar_item.year = @wine_detail.year
    @cellar_item.number = 1
    @cellar_item.wine_detail_id = @wine_detail.id
    @cellar_item.capacity = @wine_detail.capacity
  end
  
  def add
    if params[:step].to_i == 1
      @search = ::Search.new
      render :template => "mine/cellars/add_step_one"
    elsif params[:step].to_i == 2
      @search = Search.find(params[:search_id])
      render :template => "mine/cellars/add_step_two"
    end
  end

  private 
  def get_cellar
    @cellar = current_user.cellar
  end


end
