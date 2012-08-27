# encoding: utf-8
class EventParticipantsController < ApplicationController
  before_filter :get_event
  before_filter :authenticate_user!
  before_filter :get_user
  before_filter :participant, :only => [:cancle, :edit, :update]

  def index
    @participants = @event.participants
    @followers = @event.follows
  end

  def new
   @participant = @event.participants.build 
  end

  def edit

  end

  def update
    participant = @user.update_join_event_info(@participant,params[:event_participant])
    if participant
      notice_stickie "更新成功."
    else
      notice_stickie "更新失败."
    end
    redirect_to event_path(@event)
  end

  def create
    begin 
    @participant = @user.join_event(@event, params[:event_participant])
    rescue 
      notice_stickie "请不要重复提交您的信息"
    end
    redirect_to event_path(@event)
  end

  def cancle
    if request.get?

    else
      begin
        @user.cancle_join_event(@event, params[:event_participant])
        notice_stickie "取消成功"
        redirect_to event_path(@event)
      rescue ::EventException::HaveNoJoinedEvent
        render_404('')
      end
    end
  end

  def destroy
  end

  protected

  def get_user
    @user = current_user
  end

  def check_joined
    rails ::EventException::HaveJoinedEvent if @event.have_been_joined? @user.id
  end

  def get_event
   @event ||= Event.find(params[:event_id]) 
  end

  def check_joined
    @event.have_been_joined? @user.id
  end

  def participant
    @participant ||= EventParticipant.find(params[:id])
  end

end
