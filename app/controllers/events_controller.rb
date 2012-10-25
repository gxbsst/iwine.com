# encoding: utf-8
class EventsController < ApplicationController

  include Helper::EventsControllerHelper

  before_filter :authenticate_user!, :except => [:show, :index, :followers, :participants]
  before_filter :get_user, :except => [:index]
  before_filter :get_create_events, :only => [:index] 
  before_filter :get_join_events, :only => [:index]
  before_filter :get_follow_events, :only => [:index]
  before_filter :get_event, :except => [:new, :create, :index]
  before_filter :check_owner, :except => [:show, :new, :create, :index, :followers, :participants, :photo_upload]
  before_filter :get_follow_item, :only => [:show, :followers, :participants]
  before_filter :get_join_item, :only => [:show, :photo_upload, :followers, :participants]
  before_filter :check_and_create_albums, :only => [:photo_upload]

  def index
    @top_events = Event.recommends(2)
    @recommend_events = Event.recommends(4)
    @events = Event.search(params)

    if !(@events.nil?)
      unless @events.kind_of?(Array)
        @events = @events.page(params[:page]).per(6)
      else
        @events = Kaminari.paginate_array(@events).page(params[:page]).per(6)
      end
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
      notice_stickie "保存成功."
      redirect_to edit_event_path(@event)
    else
      render :action => :new
    end
  end

  def edit
   render_404('')  unless @event.editable?
   @event = Event.includes(:wines => [:wine_detail]).find(params[:id]) 
  end

  def update
    render_404('')  unless @event.editable?
    respond_to do |wants|
      if params_has?(:poster)    # 上传海报
        do_upload_poster(wants)
      elsif params_has?(:crop_x)  # 编辑海报
        crop_poster(wants)
      elsif params_has?(:title)   # 更新活动的基本信息
        if @event.update_attributes(build_old_event)
          notice_stickie "更新成功."
          wants.html { redirect_to(edit_event_path(@event)) }
        else
          wants.html { render :action => "edit" }
        end
      else
        wants.html { render :action => "edit" }
      end
    end
  end

  def show
    @event = Event.includes([:participants => [:user], :follows => [:user]]).find(params[:id])

    if user_signed_in? # 登录用户对自己的活动有所有权
      unless current_user.is_owner_of_event? @event
        @event = Event.includes([:participants => [:user], :follows => [:user]]).
          published.
          find(params[:id])
      end
    else
      @event = Event.includes([:participants => [:user], :follows => [:user]]).
        published.find(params[:id])
    end

    order = "votes_count DESC, created_at DESC"
    page = params[:params] || 1
    @comments  = Comment.for_event(@event.id).with_votes.order(order).all
    if !(@comments.nil?)
      unless @comments.kind_of?(Array)
        @comments = @comments.page(page).per(8)
      else
        @comments = Kaminari.paginate_array(@comments).page(page).per(10)
      end
    end
    @photos =  @event.photos.approved.limit(4)
    new_normal_comment
    @recommend_events = Event.recommends(4)

    # 参与活动的人
    @participants = @event.participants
    # 感兴趣的人
    @follows= @event.follows
  end

  def destroy
    @event.destroy
    respond_to do |wants|
      wants.html { redirect_to(events_path) }
    end
  end

  def photo_upload
    @photo = @event.photos.new
  end

  def upload_poster
  end

  def published
   begin
     @event.published!
     notice_stickie "活动发布成功."
     redirect_to event_path(@event)
   rescue ::EventException::EventHaveCancled
     notice_stickie e.message
     redirect_to event_path(@event)
   rescue
     render 'edit'
   end
  end

  def cancle
    begin
     @event.cancle!
     notice_stickie "活动取消成功."
    rescue ::EventException::EventHaveCancled
     notice_stickie e.message
    end
     redirect_to event_path(@event)
  end

  def draft
    begin
     @event.draft!
     notice_stickie "活动存为草稿成功."
    rescue ::EventException::EventHaveCancled => e
     notice_stickie e.message
    rescue ::EventException::EventHavePublished => e
     notice_stickie e.message
    end
     redirect_to event_path(@event)
  end

  def participants
    @event = Event.includes([:participants => [:user], :follows => [:user]]).find(params[:id])

    #if user_signed_in? # 登录用户对自己的活动有所有权
      #unless current_user.is_owner_of_event? @event
        #@event = Event.includes([:participants => [:user], :follows => [:user]]).
          #published.
          #find(params[:id])
      #end
    #else
      #@event = Event.includes([:participants => [:user], :follows => [:user]]).
        #published.find(params[:id])
    #end
    @recommend_events = Event.recommends(4)

    # 参与活动的人
    @participants = @event.participants

  end

  def followers
    @event = Event.includes([:participants => [:user], :follows => [:user]]).find(params[:id])

    #if user_signed_in? # 登录用户对自己的活动有所有权
      #unless current_user.is_owner_of_event? @event
        #@event = Event.includes([:participants => [:user], :follows => [:user]]).
          #published.
          #find(params[:id])
      #end
    #else
      #@event = Event.includes([:participants => [:user], :follows => [:user]]).
        #published.find(params[:id])
    #end
    @recommend_events = Event.recommends(4)

    @follows= @event.follows

  end

  private

  def get_event
   @event ||= Event.find(params[:id])
  end

  def get_user
   @user ||= current_user 
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

  def crop_poster(wants)
    event = params[:event]
    @event.attributes = {:crop_x => event[:crop_x],
                               :crop_y => event[:crop_y],
                               :crop_h => event[:crop_h],
                               :crop_w => event[:crop_w]}
    @event.save # skipping validate
    notice_stickie "更新成功."
    wants.html { redirect_to(edit_event_path(@event)) }
  end

  def new_normal_comment
    @commentable = @event
    @comment = @commentable.comments.build
    @comment.do = "comment"
    return @comment
  end

  # 登录用户是否关注活动
  def get_follow_item
    if !user_signed_in? 
      nil
    else
      @follow_item = @event.have_been_followed? @user.id
      @follow_item ? @follow_item : nil
    end
  end

  # 登录用户是否已经参加活动
  def get_join_item
    if !user_signed_in? 
      nil
    else
      @participant = @event.have_been_joined? @user.id
      @participant ? @participant : nil
    end
  end

  # 获取当前用户参加的活动
  def get_join_events(limit=1)
    if !user_signed_in? 
      nil
    else
      @join_events = Event.published.with_participant_for_user(current_user.id).limit(limit)
      @join_events ? @join_events : nil
    end
  end

  # 获取当前用户关注的活动
  def get_follow_events(limit=1)
    if !user_signed_in? 
      nil
    else
      @follow_events = Event.published.with_follow_for_user(current_user.id).limit(limit)
      @follow_events ? @follow_events : nil
    end
  end

  # 获取当前用户创建的活动
  def get_create_events(limit=1)
    if !user_signed_in? 
      nil
    else
      @create_events = Event.published.with_create_for_user(current_user.id).limit(1)
      @create_events ? @create_events : nil
    end
  end

  def do_upload_poster(wants)
    notice_stickie "上传成功."
    @event.update_attribute(:poster, params[:event][:poster])
    wants.html { redirect_to(upload_poster_event_path(@event)) }
  end

  def params_has?(params_key)
    if params[:event].present?
      params[:event].has_key?(params_key)
    else
      false
    end
  end

end


