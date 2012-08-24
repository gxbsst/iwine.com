# encoding: utf-8
class EventsController < ApplicationController

  include Helper::EventsControllerHelper

  before_filter :authenticate_user!, :except => [:show, :index]
  before_filter :get_user, :except => [:index]
  before_filter :get_event, :except => [:new, :create, :index]
  before_filter :check_owner, :except => [:show, :new, :create, :index]

  def index
    @top_events = Event.recommends(2)
    @recommend_events = Event.recommends(4)
    @events = Event.published.page(params[:page] || 1 ).per(5)
    respond_to do |wants|
      wants.html # index.html.erb
    end
  end

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
        notice_stickie ("上传成功.")
        @event.update_attribute(:poster, params[:event][:poster])
        wants.html { redirect_to( upload_poster_event_path(@event)) }
      elsif params[:event][:crop_x].present?
        crop_poster
        notice_stickie ("更新成功.")
        wants.html { redirect_to(edit_event_path(@event)) }
      else
        if @event.update_attributes(build_old_event)
          notice_stickie ("更新成功.")
          wants.html { redirect_to(edit_event_path(@event)) }
        else
          wants.html { render :action => "edit" }
        end
      end
    end
  end

  def show
    order = "votes_count DESC, created_at DESC"
    @comments  =  @event.comments.all(:include => [:user],
                                      # :joins => :votes,
                                      :joins => "LEFT OUTER JOIN `votes` ON comments.id = votes.votable_id",
                                      :select => "comments.*, count(votes.id) as votes_count",
                                      :conditions => ["parent_id IS NULL"], :group => "comments.id",
                                      :order => order )
    page = params[:params] || 1
    new_normal_comment
    @recommend_events = Event.recommends(4)
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

  def published
   @event.publish_status = params[:publish_status]
   if @event.save
     redirect_to events_path
   else
     render_404('')
   end
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

 def new_normal_comment
    @commentable = @event
    @comment = @commentable.comments.build
    @comment.do = "comment" 
    return @comment   
  end


end
