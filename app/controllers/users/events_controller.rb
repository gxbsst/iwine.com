# encoding: utf-8
class Users::EventsController < ApplicationController
  before_filter :get_user
  before_filter :get_recommends_event
  before_filter :authenticate_user!, :only => [:participants]

  # 活动
  def index
    @title = ["活动", title_username(@user)].join("-")
    @create_events = @user.create_events(2)
    @follow_events = @user.follow_events(2)
    @join_events   = @user.join_events(2)
  end

  def create_events
    @title = ["创建的活动", title_username(@user)].join("-")
    @events = @user.create_events(1000).page(params[:page] || 1).per(5)
  end

  def join_events
    @title = ["参加的活动", title_username(@user)].join("-")
    @events = @user.join_events(1000).page(params[:page] || 1).per(5)
  end

  def follow_events
    @title = ["感兴趣的活动", title_username(@user)].join("-")
    @events = @user.follow_events(1000).page(params[:page] || 1).per(5)
  end

  def participants
    @event = Event.find(params[:id])
    @title = ['参与者', @event.title].join('-')
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
