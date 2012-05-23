class WineriesController < ApplicationController
  before_filter :get_hot_wines, :except => :index
  before_filter :get_winery, :except => [:show, :index]
  def index
    @timelines = Wines::Detail.timeline_events.page(params[:page] || 1 ).per(6)
  end

  def show
    @winery = Winery.includes([:info_items, :photos]).find(params[:id])
    @wines = @winery.wines.includes([:details => :photos]).limit(5)
    @users = @winery.followers(:limit => 16)#关注酒庄的人
    @comments = Comment.get_comments(@winery, :limit => 10)
  end

  def photos_list
    @photos = @winery.photos.order("updated_at desc").page(params[:page] || 1).per(8)
  end

  def photo
    @photo = @winery.photos.find(params[:photo_id])
  end

  def wines_list

  end

  private
  def get_winery
    @winery = Winery.find(params[:id])
  end
  #热门酒款
  def get_hot_wines
    @hot_wines = Wines::Detail.hot_wines(:order => "desc", :limit => 5)
  end
end
