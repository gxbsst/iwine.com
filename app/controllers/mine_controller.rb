# -*- coding: utf-8 -*-
class MineController < ApplicationController
  before_filter :authenticate_user!

  def index

    @followers = current_user.followers
    @followings = current_user.followings
    @comments = current_user.comments

  end

  def unfollow
    friendship = Friendship.first :conditions => { :user_id => params[:user_id] , :follower_id => current_user.id }

    if friendship.present?
      friendship.destroy
    end

    redirect_to request.referer
  end

  # 关注的酒
  def wine_follows

  end

  # 我的评论
  def comments
    @comments = Wines::Comment.all
  end

  def testing_notes

  end

  def followings
    
    @followings = Friendship
      .includes([:user])
      .where(["follower_id = ?", current_user.id])
      .order("id DESC")
      .page params[:page] || 1

    @recommend_users = current_user.remove_followings_from_user User.all :conditions =>  "id <> "+current_user.id.to_s , :limit => 5

  end

  def followers
    @followers = Friendship
      .includes([:follower])
      .where(["user_id = ?", current_user.id])
      .order("id DESC")
      .page params[:page] || 1

    @recommend_users = current_user.remove_followings_from_user User.all :conditions =>  "id <> "+current_user.id.to_s , :limit => 5
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
