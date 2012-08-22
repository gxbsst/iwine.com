# encoding: utf-8
class EventsController < ApplicationController

  include Helper::EventsControllerHelper

  before_filter :authenticate_user!, :except => [:show]
  before_filter :get_user, :except => [:show]
  before_filter :get_event, :only => [:show, :edit, :update, :destroy]

  def new
    @event = Event.new
    respond_to do |format|
      format.html # new.html.erb
      format.json  { render :json => @event }
    end
  end

  def create
    event = params[:event]
    @event = @user.events.build(
      :title => event[:title],
      :description => event[:description],
      :begin_at => event[:begin_at],
      :end_at => event[:end_at],
      :block_in=> event[:block_in],
      :tag_list => event[:tag_list],
      :region_id => event[:region_id].to_i,
      :address => event[:address]
    )
    if @event.save
      redirect_to new_event_event_wine_path(@event)
    else
      render :action => :new
    end
  end

  def edit
  end

  def update
  
    respond_to do |wants|
      if @event.update_attributes(params[:event])
        flash[:notice] = 'Event was successfully updated.'
        wants.html { redirect_to(edit_event_path(@event)) }
      else
        wants.html { render :action => "edit" }
      end
    end
  end

  def show
    respond_to do |wants|
      wants.html # show.html.erb
    end
  end

  def destroy
    @event.destroy
    respond_to do |wants|
      wants.html { redirect_to(events_path) }
    end
  end
  private
  
  def get_event
   @event = Event.find(params[:id]) 
  end

  def get_user
   @user = current_user 
  end
end
