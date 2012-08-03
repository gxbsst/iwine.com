module Api
  class BaseApiController < ApplicationController
    respond_to :json

    protected

    def user_info_json
      return {:success => true, 
        :user => {
        :id => @user.id,
        :email => @user.email,
        :username => @user.username,
        :slug => @user.slug,
        :avatar => @user.avatar.url,
        :city => @user.city ? @user.city : "",
        :bio => @user.profile.bio ? @user.profile.bio : "",
        :pofile_id => @user.profile.id}} 
    end
    
  end
end
