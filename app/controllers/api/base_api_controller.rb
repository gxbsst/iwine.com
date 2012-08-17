module Api
  class BaseApiController < ApplicationController
    respond_to :json

    protected

    def user_info_json( is_public = false)
      return {:success => 1, 
        :resultCode =>  APP_DATA["api"]["return_json"]["normal_success"]["code"].to_i,
        :errorDesc =>  APP_DATA["api"]["return_json"]["normal_success"]["message"],
        :user => 
        {
          :auth_toke => @user.authentication_token,
          :id => @user.id,
          :email => is_public ? '' : @user.email,
          :username => @user.username,
          :slug => @user.slug,
          :avatar => @user.avatar.url,
          :city => @user.city ? @user.city : "",
          :bio => @user.profile.bio ? @user.profile.bio : "",
          :phone_number => @user.profile.phone_number ? @user.profile.phone_number : '',
          :birthday => @user.profile.birthday ? @user.profile.birthday : '',
          :pofile_id => @user.profile.id
        }
      } 
    end
    
  end
end
