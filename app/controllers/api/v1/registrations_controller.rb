# encoding: utf-8
# 参考:
#  https://gist.github.com/1255275
#  http://jessewolgamott.com/blog/2012/01/19/the-one-with-a-json-api-login-using-devise/

module Api
  module V1
    class RegistrationsController < ::Api::BaseApiController

      def index

      end

      def create
        user = User.new(params[:user])
        if user.save
          #render :json => user.as_json(:auth_token=>user.authentication_token,
          #user = User.find_by_email(user.email) # 主要为了获取用户的激活码
          render :json => build_json(user), :resultCode => 201
          return
        else
          warden.custom_failure!
          render :json => user.errors, :resultCode => 422
        end
      end

      protected
      def build_json(resource)
        return {:success => 1, 
          :user => {
          :email => resource.email,
          :username => resource.username,
          :confirmation_token => resource.confirmation_token,
          :id => resource.id}
        }
      end

    end
  end
end
