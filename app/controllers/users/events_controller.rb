class Users::EventsController < ApplicationController
  before_filter :get_user
  before_filter :get_recommends_event
  before_filter :authenticate_user!, :only => [:participants]

  # 活动
  def index
    @create_events = @user.create_events(2)
    @follow_events = @user.follow_events(2)
    @join_events   = @user.join_events(2)
  end

  def create_events
    @events = @user.create_events(1000).page(params[:page] || 1).per(5)
  end

  def join_events
    @events = @user.join_events(1000).page(params[:page] || 1).per(5)
  end

  def follow_events
    @events = @user.follow_events(1000).page(params[:page] || 1).per(5)
  end

  def participants
    @event = Event.find(params[:id])
    if current_user.is_owner_of_event? @event
      @participants = @event.participants.page(params[:page] || 1).per(5)
    else
      render_404('')
    end
  end

  private

  def get_user
    @user ||= User.find(params[:user_id])
  end

  def get_recommends_event
    @recommend_events ||= Event.recommends(4)
  end

end
