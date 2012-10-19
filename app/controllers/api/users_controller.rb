# encoding: utf-8
class Api::UsersController < ApplicationController
  before_filter :authenticate_user!, :except => [:name]
  before_filter :get_user, :except => [:name]
  def names
      @users = User.active_user.where("username like ? and id != ? ", "%#{params[:term]}%", current_user.id).order("updated_at desc").limit(15)
      render json: @users.collect{|u| u[:username]}
  end

  def friends
    @users = @user.friends
    render json: @users.map_user.collect{|user| {:id => user.id} }
  end

  protected

  def get_user
    @user ||= current_user
  end
end
