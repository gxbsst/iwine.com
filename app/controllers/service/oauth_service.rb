#encoing: utf-8
module Service
  module OauthService

    class Binding  #

      # params {:oauth_user => {:sns_user_id => "....", :sns_name => "weibo"}}
      def self.process(user, params)
        new(user, params).create
      end

      def initialize(user, params)
        @user = user
        @params = params
      end

      def create
       params[:oauth_user][:sns_user_id] = sns_user_id
       params[:oauth_user][:setting_type] = setting_type('binding')
       oauth_user =  Users::Oauth.where(:user_id => @user.id, :sns_name => @params[:oauth_user][:sns_name]).first_or_initialize
       oauth_user.attributes = @params
       oauth_user.save
      end

      def setting_type(type)  # binding Or login
        APP_DATA['user_oauths']['setting_type'][type]
      end

      def sns_user_id
        params[:oauth_user][:provider_user_id]
      end

    end

  end
end