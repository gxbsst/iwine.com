
module Api
  module V1
    class ConfirmationsController < ::Api::BaseApiController
      respond_to :json

      def index
        resource = User.confirm_by_token(params[:confirmation_token])
        if resource.errors.empty?
          render :json =>  {:success => 1, 
            :resultCode =>  APP_DATA["api"]["return_json"]["normal_success"]["code"].to_i,
            :errorDesc =>  APP_DATA["api"]["return_json"]["normal_success"]["message"]
          }
        else
          render :json =>  {:success => 0, 
            :resultCode =>  APP_DATA["api"]["return_json"]["normal_failed"]["code"].to_i,
            :errorDesc =>  APP_DATA["api"]["return_json"]["normal_failed"]["message"]
          }
        end
      end

    end
  end
end

