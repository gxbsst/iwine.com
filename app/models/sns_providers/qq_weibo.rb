# encoding: utf-8
module SnsProviders
  class QqWeibo < ::UserSnsFriend

    SNS_NAME = 'qq'

    class << self

      def sync
        oauth_users = Users::Oauth.where(:sns_name => SNS_NAME)
        oauth_users.each do |oauth_user|
          create_friend(oauth_user)
        end
      end

    end

  end

end
