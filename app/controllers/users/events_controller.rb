class Users::EventsController < ApplicationController
  before_filter :get_user
  # 活动
  def index
    @create_events = @user.create_events(3)
    @follow_events = @user.follow_events(3)
    @join_events   = @user.join_events(3)
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

  private

  def get_user
    @user ||= User.find(params[:user_id])
  end

end
