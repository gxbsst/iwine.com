# -*- coding: utf-8 -*-
class MineController < ApplicationController
  before_filter :authenticate_user!

  def index

    @followers = current_user.followers
    @followings = current_user.followings
    @comments = current_user.comments

  end

  # 关注的酒
  def wine_follows

  end

  # 我的评论
  def simple_comments

  end

  def followings
    
    @followings = Friendship
      .includes([:user])
      .where(["follower_id = ?", current_user.id])
      .order("id DESC")
      .page params[:page] || 1

  end

  def wish

  end

  def do

  end

  def feeds

  end

  def status

  end
end