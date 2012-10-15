# encoding: utf-8
class WineriesController < ApplicationController
  before_filter :authenticate_user!, :only => [:photo_upload]
  before_filter :get_hot_wineries, :except => [:index, :photo_upload]
  before_filter :get_winery, :except => [:show, :index]
  before_filter :get_follow_item, :except => [:index]
  before_filter :check_and_create_albums, :only => [:photo_upload]
  
  def index
    @title = "酒庄"
    @timelines = Winery.timeline_events
    page = params[:page] || 1

    if !(@timelines.nil?)
      unless @timelines.kind_of?(Array)
        @timelines = @timelines.page(page).per(30)
      else
        @timelines = Kaminari.paginate_array(@timelines).page(page).per(30)
      end
    end
  end

  def show
    @winery   = Winery.includes([:info_items, :photos]).find(params[:id])
    @wines    = @winery.wines.includes([:details => :photos]).limit(5)
    @users    = @winery.followers #关注酒庄的人
    @comments = Comment.get_comments(@winery, :limit => 10)
    @title    = @winery.name
  end

  def wines_list
    @title = ["所有酒", @winery.name].join("-")
    @wines = @winery.wines.includes([:details => :photos]).page(params[:page] || 1).per(10)
  end

  def followers_list
    @title = ["关注者", @winery.name].join("-")
    @users = @winery.followers(:page => params[:page], :per => 10)
  end
  
  def photo_upload
    @photo = @winery.photos.new
  end 

  private

  def get_winery
    @winery = Winery.find(params[:id])
  end

  #热门酒
  def get_hot_wines
    @hot_wines = Wines::Detail.hot_wines(5)
  end

  #热门酒庄
  def get_hot_wineries
    @hot_wineries = Winery.hot_wineries(5)
  end

  private
  # 登录用户是否关注酒庄
  def get_follow_item
    @winery = Winery.find(params[:id])
    if !user_signed_in? 
      nil
    else
      if @follow_item = (@winery.is_followed_by? current_user)
        @follow_item 
      else
        nil
      end
    end
  end

end
