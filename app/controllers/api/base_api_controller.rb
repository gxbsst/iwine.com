module Api
  class BaseApiController < ApplicationController
    respond_to :json

    protected

    def user_info_json
      return {:success => true, 
        :resultCode =>  APP_DATA["api"]["return_json"]["normal_success"]["code"],
        :errorDesc =>  APP_DATA["api"]["return_json"]["normal_success"]["message"],
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
