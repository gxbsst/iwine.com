# encoding: utf-8
  class ::SnsProviders::SinaWeibo < ::UserSnsFriend

    SNS_NAME = 'weibo'

    class << self

      def sync
        oauth_users = Users::Oauth.where(:sns_name => SNS_NAME)
        oauth_users.each do |oauth_user|
          create_friend(oauth_user)
        end
      end

    end

  end

