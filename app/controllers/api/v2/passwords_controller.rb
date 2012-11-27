# encoding: utf-8
module Api
  module V2
    class PasswordsController < ::Api::BaseApiController
      def create
        resource_name = :user
        resource_class = User
        resource = resource_class.send_reset_password_instructions(params[resource_name])
        render :json => UserJsonSerializer::PasswordJsonSerializer.as_json(resource)
      end

    end
  end
end