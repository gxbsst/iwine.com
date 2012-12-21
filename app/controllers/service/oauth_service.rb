#encoing: utf-8
module Service
  module OauthService

    class Binding  #

      # params {:oauth_user => {:sns_user_id => "....", :sns_name => "weibo", :access_token => ""}}
      def self.process(user, params = {}, &block)
        raise "No Access Token " unless params[:oauth_user][:access_token].present?
        new(user, params, block).create
      end

      def initialize(user, params, block)
        @user = user
        @params = params
        @block = block
      end

      def create
       @params[:oauth_user][:sns_user_id] = sns_user_id
       @params[:oauth_user][:setting_type] = setting_type()
       oauth_user = @user.oauths.oauth_binding.where(:sns_name => sns_name).first_or_initialize
       oauth_user.attributes = @params[:oauth_user]
       oauth_user.save
       @block.call(oauth_user) if @block
       oauth_user
      end

      def setting_type(type = 'binding')  # binding Or login
        APP_DATA['user_oauths']['setting_type'][type]
      end

      def sns_user_id
        @params[:oauth_user][:provider_user_id]
      end

      def build_oauth_user
        p = {:oauth_user => {:sns_user_id => sns_user_id, :setting_type => setting_type}}
        p.merge(@params)
      end

      def sns_name
        @params[:oauth_user][:sns_name]
      end

      def uid
        @user.id
      end

    end

    class UnBinding  #

      # params {:oauth_user => {:sns_user_id => "....", :sns_name => "weibo"}}
      def self.process(user, params = {}, &block)
        new(user, params, block).delete
      end

      def initialize(user, params, block)
        @user = user
        @params = params
        @block = block
      end

      def delete
        user_oauth = ::Users::Oauth.oauth_binding.where("user_id = ? and sns_name  = ? ", uid, sns_name).first
        @block.call(user_oauth) if @block
        user_oauth.delete if user_oauth.present?
      end

      def setting_type(type)  # binding Or login
        APP_DATA['user_oauths']['setting_type'][type]
      end

      def uid
        @user.id
      end

      def sns_name
        @params[:oauth_user][:sns_name]
      end

    end

  end
end