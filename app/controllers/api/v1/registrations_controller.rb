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

          render :json => build_json(user), :status => 201
          return
        else
          warden.custom_failure!
          render :json=> user.errors, :status => 422
        end
      end

      protected
      def build_json(resource)
        return {:success => true, 
                :user => {
                  :email => resource.email,
                  :username => resource.username,
                  :id => resource.id}}
      end

    end
  end
end
