class WineriesController < ApplicationController
  before_filter :get_hot_wineries, :except => :index
  before_filter :get_winery, :except => [:show, :index]
  def index
    @timelines = Winery.timeline_events.page(params[:page] || 1 ).per(12)
  end

  def show
    @winery = Winery.includes([:info_items, :photos]).find(params[:id])
    @wines = @winery.wines.includes([:details => :photos]).limit(5)
    @users = @winery.followers #关注酒庄的人
    @comments = Comment.get_comments(@winery, :limit => 10)
  end

  def wines_list
    @wines = @winery.wines.includes([:details => :photos]).page(params[:page] || 1).per(10)
  end

  def followers_list
    @users = @winery.followers(:page => params[:page], :per => 10)
  end

  private
  def get_winery
    @winery = Winery.find(params[:id])
  end

  #热门酒款
  def get_hot_wines
    @hot_wines = Wines::Detail.hot_wines(5)
  end

  #热门酒庄
  def get_hot_wineries
    @hot_wineries = Winery.hot_wineries(5)
  end
end
