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
  end

  def followers
    followers = Friendship.all :conditions => { :user_id => current_user.id }
  end

  def followings
    followings = Friendship.all :conditions => { :follower_id => current_user.id }
  end

end