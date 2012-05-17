class WineriesController < ApplicationController
  def index
      @timelines = Wines::Detail.timeline_events.page(params[:page] || 1 ).per(6)
  end

  def show
    @winery = Winery.includes([:info_items, :photos]).find(params[:id])
  end
end
