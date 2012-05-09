class HomeController < ApplicationController
  before_filter :authenticate_user!
  before_filter :get_user
  
  def index
    @timelines = Users::Timeline.where("user_id=#{@user.id}").includes(:timeline_event => [:actor, :subject]).order("created_at DESC")
  end

  def show

  end

  def edit

  end

  def create

  end

  def new

  end
  
  private 
  def get_user
    @user = current_user
  end
end