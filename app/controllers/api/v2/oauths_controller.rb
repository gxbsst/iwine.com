# encoding: utf-8
module Api
  module V2
    class OauthsController < ::Api::BaseApiController
      before_filter :authenticate_user!, :only => [:bind]

      def create
        #TODO: 如果不存在用户则返回告诉让他注册
        @user = create_new_user
        sign_in @user, :bypass => true
        @user.reset_authentication_token!
        # user_id, sns_name, sns_user_id
        params[:oauth_user][:user_id] = @user.id
        if create_user_oauth(params[:oauth_user])
          render :json =>  user_info_json
        else
          render :json => {:success => false,
                           :resultCode =>  APP_DATA["api"]["return_json"]["normal_failed"]["code"],
                           :errorDesc =>  APP_DATA["api"]["return_json"]["normal_failed"]["message"],
                           :message => @user_oauth.errors }, :status => 422
        end
      end

      def bind
        resource = Service::OauthService::Binding.process(current_user, params)
        status = resource.errors.any? ? true : false
        render :json => ::Api::Helpers::ReportJsonSerializer.as_json(resource, status)
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

      #def get_user
       #@user = current_user 
      #end

      #创建虚拟用户，以便用户登录
      def create_new_user
        oauth_user = params[:oauth_user]
        email = generate_email(oauth_user[:sns_user_id], oauth_user[:sns_name])
        @user = User.find_by_email(email)
        unless @user.present?
          password = generate_pass
          @user = User.new(:username => oauth_user[:sns_user_id] + '_'+ SecureRandom.random_number(10000).to_s,
                           :email => email,
                           :password => password,
                           :password_confirmation => password
                           )
          @user.confirmed_at = Time.now
          @user.save
        end
        @user
      end
      
      def generate_pass
        (0...10).map{65.+(rand(25)).chr}.join 
      end

      def generate_email(sns_user_id, sns_name)
        Base64.strict_encode64(sns_user_id) + '_' + sns_name + '@iwine.com'
      end

    end
  end
end
