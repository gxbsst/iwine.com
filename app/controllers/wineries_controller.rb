class WineriesController < ApplicationController
  def index
      @timelines = Wines::Detail.timeline_events.page(params[:page] || 1 ).per(6)
  end

  def show
    @winery = Winery.includes([:info_items, :photos]).find(params[:id])
    @hot_wines = Wines::Detail.hot_wines(:order => "desc", :limit => 5)#热门酒款
    @wines = @winery.wines.includes([:details => :photos]).limit(5)
    @users = @winery.followers(:limit => 16)#关注酒庄的人
  end
end
