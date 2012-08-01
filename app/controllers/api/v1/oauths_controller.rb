module Api
  module V1
    class OauthsController < ::Api::BaseApiController
      before_filter :authenticate_user!

      def create
        # user_id, sns_name, sns_user_id
        #@oauth_user = Users::Oauth.
          #find_by_sns_name_and_sns_user_id(params[:oauth_user][:sns_name], 
                                           #params[:oauth_user][:sns_user_id])
        @oauth_user = Users::Oauth.new(params[:oauth_user])
        respond_to do |wants|
          if @oauth_user.save
            wants.json  {render :json => {:success => true}}
          else
            wants.json  {render :json => {:sucess => false}}
          end
        end
      end
    end
  end
end
