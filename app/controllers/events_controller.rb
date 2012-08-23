# encoding: utf-8
class EventsController < ApplicationController

  include Helper::EventsControllerHelper

  before_filter :authenticate_user!, :except => [:show]
  before_filter :get_user, :except => [:show]
  before_filter :get_event, :except => [:new, :create]
  before_filter :check_owner, :except => [:show, :new, :create]

  def new
    @event = Event.new
    respond_to do |format|
      format.html # new.html.erb
      format.json  { render :json => @event }
    end
  end

  def create
    event = params[:event]
    @event = build_new_event
    if @event.save
      redirect_to new_event_event_wine_path(@event)
    else
      render :action => :new
    end
  end

  def edit
   @event = Event.includes(:wines => [:wine_detail]).find(params[:id]) 
  end

  def update
    respond_to do |wants|
      if params[:event][:poster].present?
        @event.update_attribute(:poster, params[:event][:poster])
        wants.html { redirect_to( upload_poster_event_path(@event)) }
      elsif params[:event][:crop_x].present?
        crop_poster
        notice_stickie t("notice.photo.upload_avatar_success")
        wants.html { redirect_to(edit_event_path(@event)) }
      else
        if @event.update_attributes(build_old_event)
          flash[:notice] = 'Event was successfully updated.'
          wants.html { redirect_to(new_event_event_wine_path(@event)) }
        else
          wants.html { render :action => "edit" }
        end
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

  def upload_poster
    
  end

  private
  
  def get_event
   @event = Event.find(params[:id]) 
  end

  def get_user
   @user = current_user 
  end

  def build_new_event
    event = params[:event]
    return  @user.events.build(
      :title => event[:title],
      :description => event[:description],
      :begin_at => event[:begin_at],
      :end_at => event[:end_at],
      :block_in=> event[:block_in],
      :tag_list => event[:tag_list],
      :region_id => event[:region_id].to_i,
      :address => event[:address]
    )
  end


  def build_old_event
    event = params[:event]
    return { 
      :title => event[:title],
      :description => event[:description],
      :begin_at => event[:begin_at],
      :end_at => event[:end_at],
      :block_in=> event[:block_in],
      :tag_list => event[:tag_list],
      :region_id => event[:region_id].to_i,
      :address => event[:address]
    } 
  end

  def crop_poster
    event = params[:event]
    @event.attributes = {:crop_x => event[:crop_x],
                               :crop_y => event[:crop_y],
                               :crop_h => event[:crop_h],
                               :crop_w => event[:crop_w]}
    @event.save # skipping validate
  end

end
