# -*- coding: utf-8 -*-
class MineController < ApplicationController
  before_filter :authenticate_user!
  before_filter :get_user

  def index
    @followers = current_user.followers
    @followings = current_user.followings
    @comments = current_user.comments
    @cellar = current_user.cellar
    @following_wines = current_user.following_wines
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

  def feeds

  end

  def status

  end

  private

  def get_user
    @user = current_user
  end
end