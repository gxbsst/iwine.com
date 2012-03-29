class FriendsController < ApplicationController
  

  def follow
    @oauth_list = Users::Oauth.all :conditions => { :user_id => current_user.id }
  end


end