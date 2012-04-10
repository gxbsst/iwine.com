# -*- coding: utf-8 -*-
class FriendsController < ApplicationController
  
  def follow
    friendship = Friendship.new
    friendship.user_id = params[:user_id]
    friendship.follower_id = current_user.id
    friendship.save
  end

  def unfollow
    friendship = Friendship.first :conditions => { :user_id => params[:user_id] , :follower_id => current_user.id }
    if friendship.present?
      friendship.destroy
    end

  # 查找好友
  def find

  end

  # 查找好友结果
  def find_result

  end

  # 设置同步
  def sync

  end

  def find_email_friends

  end

  def index

  end

  def invite

  end

  def followers
    @followers = current_user.followers
  end

  def followings
    @followings = current_user.followings
  end

  def sync 
    client = current_user.oauth_client( params[:sns_name] )
    @friends = client.friends
  end

  def sns

  end

end
