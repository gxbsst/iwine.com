# encoding: utf-8
class Api::UsersController < ApplicationController
  def names
      @users = User.where("username like ?", "%#{params[:term]}%").order("updated_at desc").limit(15)
      render json: @users.collect{|u| u[:username]}
  end
end