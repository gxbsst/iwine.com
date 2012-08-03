module Api
  module V1
    class OauthsController < ::Api::BaseApiController
      before_filter :authenticate_user!
      before_filter :get_user

      def create
        # user_id, sns_name, sns_user_id
        if create_user_oauth(params[:oauth_user])
          render :json =>  user_info_json
        else
          render :json => @user_oauth.errors, :status => 422
        end
      end
      
      protected
     
      def create_user_oauth(params)
       if @user.has_oauth_item? params
         true
       else
         params[:user_id] = @user.id
        if @user_oauth = Users::Oauth.create(params)
          true
        else
          false
        end
        
       end
      end

      def get_user
       @user = current_user 
      end

    end
  end
end
