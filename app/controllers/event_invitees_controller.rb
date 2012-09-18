# encoding: utf-8
class EventInviteesController < ApplicationController

  include Helper::EventsControllerHelper

  before_filter :authenticate_user!
  before_filter :get_user
  before_filter :get_event
  before_filter :check_owner
  before_filter :get_follow_item
  before_filter :get_join_item

  def new
    @recommend_events = Event.recommends(4)
    @event_invitee =  EventInvitee.new
    @users = @user.friends
    #@users = @user.friends.page(params[:page] || 1).per(22) #per(48)
  end

  def create
    if params[:users].blank?
     render_404('') # 传错误的参数
    else
      params[:users].each do |user_id|
        @user.invite_one(user_id, @event)
      end
      notice_stickie "您的邀请已经发送..."
     redirect_to event_path(@event)
    end
  end

  private

  def get_user
   @user ||= current_user 
  end

  def get_event
   @event ||= Event.find(params[:event_id])
  end
end
