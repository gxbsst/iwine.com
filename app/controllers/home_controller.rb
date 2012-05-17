class HomeController < ApplicationController
  before_filter :authenticate_user!
  before_filter :get_user

  def index
      @timelines = @user.feeds.page(params[:page] || 1 ).per(12)
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