# encoding: utf-8
# 参考:
#  https://gist.github.com/1255275
#  http://jessewolgamott.com/blog/2012/01/19/the-one-with-a-json-api-login-using-devise/

module Api
  module V1
    class SessionsController < ::Api::BaseApiController
      before_filter :authenticate_user!, :except => [:create, :destroy]
      before_filter :ensure_params_exist
      respond_to :json

      def create
        resource = User.find_for_database_authentication(:email => params[:user][:email])
        return invalid_login_attempt unless resource

        if resource.valid_password?(params[:user][:password])
          sign_in(:user, resource)
          resource.ensure_authentication_token!
          render :json => build_json(resource)
          return
        end
        invalid_login_attempt
      end

      def destroy
        resource = User.find_for_database_authentication(:email => params[:user][:email])
        resource.authentication_token = nil
        resource.save
        render :json=> {:success=>true}
      end

      protected
      def ensure_params_exist
        return unless params[:user].blank?
        render :json=>{:success=>false, 
          :resultCode => APP_DATA["api"]["return_json"]["miss_parameter"]["code"], 
          :errorDesc => APP_DATA["api"]["return_json"]["miss_parameter"]["message"] }, 
          :status => 422
      end

      def invalid_login_attempt
        render :json=> {:success=>false,
          :resultCode => APP_DATA["api"]["return_json"]["auth_failed"]["code"], 
          :errorDesc => APP_DATA["api"]["return_json"]["auth_failed"]["message"] }, 
          :status => 401
      end

      def build_json(resource)
        return {:success => true, 
                :resultCode => APP_DATA["api"]["return_json"]["normal_success"]["code"],
                :errorDesc => APP_DATA["api"]["return_json"]["normal_success"]["message"],
                :user => {:auth_token => resource.authentication_token,
                          :email => resource.email,
                          :username => resource.username,
                          :id => resource.id,
                          :slug => resource.slug,
                          :profile_id => resource.profile.id }}
      end

    end
  end
end
