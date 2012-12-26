# encoding: utf-8
module Api
  module V2
    class OauthsController < ::Api::BaseApiController
      before_filter :authenticate_user!, :only => [:bind, :unbind]

      def create
        binded?(params) do |resource|
          return render_user_json(resource, status(resource)) if resource.present?
          if has_auth_token?(params)
            authenticate_user!
            oauth_user = create_user_oauth(params)
            render_json(oauth_user, has_errors?(oauth_user))
          else
            render_json(resource, status(resource))
          end
        end
      end

      def bind
        Service::OauthService::Binding.process(current_user, params) do |resource|
          render_json(resource, has_errors?(resource))
        end
      end

      def unbind
        Service::OauthService::UnBinding.process(current_user, params) do |resource|
          render_json(resource, has_errors?(resource))
        end
      end

      protected
     
      def create_user_oauth(params)
        params[:oauth_user][:user_id] = current_user.id
        Users::Oauth.create(params[:oauth_user])
      end

      def has_errors?(resource)
        resource.errors.any? ? false : true
      end

      def status(resource)
        resource.present? ? true : false
      end

      def render_json(resource, status)
        render :json => ::Api::Helpers::OauthJsonSerializer.as_json(resource, status)
      end

      def binded?(params, &block)
        raise "No provider name Or provider user id" unless params[:oauth_user][:sns_name] || params[:oauth_user][:provider_user_id]
        Users::Oauth.has_bind_login?(params[:oauth_user][:sns_name],
                                     params[:oauth_user][:provider_user_id],
                                     &block
                                     )
      end

      def render_user_json(resource, status)
        update_access_token(resource, params[:oauth_user][:access_token])
        render_json(authentication(resource.user), status)
      end

      def authentication(user)
        sign_in user, :bypass => true
        user.reset_authentication_token!
        user
      end

      def update_access_token(resource, token)
        raise "No token" if token.blank?
        resource.update_token(token)
      end

      def has_auth_token?(params)
        params[:auth_token].present?
      end

      #def get_binding_user
      #  oauth_user = params[:oauth_user]
      #  email = generate_email(oauth_user[:sns_user_id], oauth_user[:sns_name])
      #  @user = User.find_by_email(email)
      #  return email, oauth_user
      #end

      ##创建虚拟用户，以便用户登录
      #def create_new_user
      #  email, oauth_user = get_binding_user()
      #  unless @user.present?
      #    password = generate_pass
      #    @user = User.new(:username => oauth_user[:sns_user_id] + '_'+ SecureRandom.random_number(10000).to_s,
      #                     :email => email,
      #                     :password => password,
      #                     :password_confirmation => password
      #                     )
      #    @user.confirmed_at = Time.now
      #    @user.save
      #  end
      #  @user
      #end


      #def generate_pass
      #  (0...10).map{65.+(rand(25)).chr}.join
      #end
      #
      #def generate_email(sns_user_id, sns_name)
      #  Base64.strict_encode64(sns_user_id) + '_' + sns_name + '@iwine.com'
      #end


    end
  end
end
