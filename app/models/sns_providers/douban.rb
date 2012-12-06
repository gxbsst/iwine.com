# encoding: utf-8
module SnsProviders
  class Douban < ::UserSnsFriend
    SNS_NAME = 'douban'

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