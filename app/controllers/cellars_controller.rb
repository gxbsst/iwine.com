# encoding: UTF-8
class CellarsController < ApplicationController

  before_filter :get_user
  before_filter :get_cellar
  before_filter :get_order_type

  def show
    if params[:wine_name]
      if mine_equal_current_user?(@user)
        @cellar_items = @cellar.mine_items.joins(:wine_detail => :wine).
            where("wines.name_en like ? or wines.name_zh like ? ", "%#{params[:wine_name]}%", "%#{params[:wine_name]}%").
            order(@order).
            page params[:page] || 1
      else
        @cellar_items = @cellar.user_items.joins(:wine_detail => :wine).
            where("wines.name_en like ? or wines.name_zh like ? ", "%#{params[:wine_name]}%", "%#{params[:wine_name]}%").
            order(@order).
            page params[:page] || 1
      end
    else
      if mine_equal_current_user?(@user)
        @cellar_items = @cellar.mine_items.
            joins(:wine_detail).
            order(@order).
            page params[:page] || 1
      else
        @cellar_items = @cellar.user_items.
            joins(:wine_detail).
            order(@order).
            page params[:page] || 1
      end
    end
  end

  private 

  def get_cellar
    @cellar = @user.cellar
  end

  def get_user
    @user = User.find(params[:id])
  end

  def get_order_type
    order_hash = { "1" => "buy_date asc", "2" => "buy_date desc", "3" => "year asc", "4" => "year desc", "5" => "price asc", "6" => "price desc"}
    if params[:search_order]
      @order = order_hash[params[:search_order]]
    else
      @order = "buy_date asc"
    end
  end
end
