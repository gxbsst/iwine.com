# encoding: utf-8
# 参考:
#  https://gist.github.com/1255275
#  http://jessewolgamott.com/blog/2012/01/19/the-one-with-a-json-api-login-using-devise/

module Api
  module V2
    class RegistrationsController < ::Api::BaseApiController

      def index

      end

      def create
        user = User.new(params[:user])
        if user.valid?
          user.save
          #render :json => user.as_json(:auth_token=>user.authentication_token,
          #user = User.find_by_email(user.email) # 主要为了获取用户的激活码
          #render :json => build_json(user)
          #return
        else
          warden.custom_failure!
          #render :json => build_error_json(user.errors)
        end
        render :json => UserJsonSerializer::RegistrationJsonSerializer.as_json(user)
      end

      protected

      def build_json(resource)
        {
            :success => 1,
            :resultCode => 201,
            :user => {
                :email => resource.email,
                :username => resource.username,
                :confirmation_token => resource.confirmation_token,
                :id => resource.id}
        }
      end

      def build_error_json(error)
        {
            :success => 0,
            :resultCode => 422,
            :errorDesc => error
        }
      end


    end
  end
end
