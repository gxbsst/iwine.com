# encoding: utf-8
# 参考:
#  https://gist.github.com/1255275
#  http://jessewolgamott.com/blog/2012/01/19/the-one-with-a-json-api-login-using-devise/

module Api
  module V2
    class SessionsController < ::Api::BaseApiController
      before_filter :authenticate_user!, :except => [:create, :destroy]
      #before_filter :ensure_params_exist
      respond_to :json

      def create
        resource = User.find_for_database_authentication(:email => params[:user][:email])
        if resource && resource.valid_password?(params[:user][:password])
          sign_in(:user, resource)
          resource.ensure_authentication_token!
          render :json => UserJsonSerializer::SessionJsonSerializer.as_json(resource, true)
        else
          render :json => UserJsonSerializer::SessionJsonSerializer.as_json(resource, false)
        end
      end

      def destroy
        resource = User.find_for_database_authentication(:email => params[:user][:email])
        resource.authentication_token = nil
        resource.save
        render :json=> {:success=>true}
      end

    end
  end
end
