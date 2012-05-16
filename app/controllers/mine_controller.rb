# -*- coding: utf-8 -*-
class MineController < ApplicationController
  before_filter :authenticate_user!
  before_filter :get_user

  def index
    @followers = @user.followers
    @followings = @user.followings
    @comments = @user.comments.limit(6)
    @cellar = @user.cellar
    @following_wines = @user.wine_followings.limit(6)
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
    @comments = @user.wine_followings.page(params[:page] || 1).per(10) 
  end
  
  # 关注的酒庄
   def winery_follows
     @comments = @user.wine_followings.page(params[:page] || 1).per(10) 
     render "mine/wine_follows"
   end
   
  # 我的评论
  def comments
    @comments = @user.comments.page(params[:page] || 1).per(10) 
  end

  def testing_notes

  end

  def followings
    @followings = @user.followings.page(params[:page] || 1).per(10)
    @recommend_users = current_user.remove_followings_from_user User.all :conditions =>  "id <> "+current_user.id.to_s , :limit => 5
  end

  def followers
    @followers = @user.followers.page(params[:page] || 1).per(10)
    @recommend_users = current_user.remove_followings_from_user User.all :conditions =>  "id <> "+current_user.id.to_s , :limit => 5
  end

  private
  def get_user
    @user = current_user
  end
end
