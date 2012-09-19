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
      if !@event.joinedable? # 活动不可以参加
        notice_stickie "您的活动或许已过期、未发布、人数已满..."
        redirect_to event_path(@event)
      else
        new_array = params[:user_list].split(',').map{|user_id| user_id.to_i} &
          @user.friends.pluck(:follower_id) # 过滤错误的用户id
        new_array.each do |user_id|
          @event.invite_one_user(@user.id, user_id, :invite_log => '邀请你参加活动')
        end
        #TODO: Ian 更新通知的内容
        recipients = User.find(new_array)
        subject = "活动邀请"
        msg_body = "您的朋友邀请您参加其创建的活动"
        @event.delay.send_system_message(recipients, msg_body, subject, sanitize_text=true, attachment=nil)
        notice_stickie "您的邀请已经发送..."
        redirect_to event_path(@event)
      end
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
