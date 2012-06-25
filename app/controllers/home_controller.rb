# encoding: utf-8
class HomeController < ApplicationController
  before_filter :authenticate_user!
  before_filter :get_user

  def index
    @title = "我的首页"
    @timelines = @user.feeds.page(params[:page] || 1 ).per(30)
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
