# encoding: utf-8
class EventWinesController < ApplicationController

  include Helper::EventsControllerHelper

  before_filter :get_event
  before_filter :authenticate_user!
  before_filter :check_owner

  def new
    @event_wine = @event.wines.build
    respond_to do |wants|
      wants.html # new.html.erb
      wants.xml  { render :xml => @event_wine  }
    end
  end

  def create
    wine_detail_ids = params[:event_wine][:wine_detail_ids]
    if wine_detail_ids.present?
      wine_detail_ids.split(',').each do |wine_detail_id|
        @event.add_one_wine(wine_detail_id)
      end
      respond_to do |wants|
        notice_stickie "活动用酒创建成功" 
        wants.html { redirect_to(edit_event_path(@event)) }
      end
    else
      rails "WINE DETAIL IDS CAN NOT BE NULL"
    end
  end

  def edit
    @event_wine = EventWine.find(params[:id])
  end
 
  def update
    @event_wine = EventWine.find(params[:id])
  
    respond_to do |wants|
      if @event_wine.update_attributes(params[:event_wine])
        flash[:notice] = 'EventWine was successfully updated.'
        wants.html { redirect_to(edit_event_path(@event)) }
      else
        wants.html { render :action => "edit" }
      end
    end
  end

  private

  def get_event
   @event = Event.find(params[:event_id]) 
  end

  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end

end
