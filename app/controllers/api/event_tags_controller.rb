# encoding: utf-8
class Api::EventTagsController < ApplicationController
  def index
    @json = Wines::RegionTree.limit(10)
    respond_to do |format|
      format.json {render :json => @json}
    end
  end

  def hot_tags
    #binding.pry
    @tags = Event.tag_counts_on(:tags)
    respond_to do |format|
      format.json {render :json => @tags}
    end
  end
end

