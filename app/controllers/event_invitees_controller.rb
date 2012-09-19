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
    @invtited_friends = @event.invitees.pluck(:invitee_id)
  end

  def create
    if params[:user_list].blank?
     render_404('') # 传错误的参数
    else
      new_array = params[:user_list].split(',') & @user.friends.pluck(:id) # 过滤错误的用户id
      new_array.each do |user_id|
        @event.invite_one_user(@user.id, user_id, :invite_log => '邀请你参加活动')
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
