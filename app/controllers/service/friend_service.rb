#encoing: utf-8
module Service
  module FriendService

    class Recommend  # 某用户的推荐好友

      SNS_FRIEND = {
          'tencent' => '::SnsProviders::QqWeibo',
          'qq' =>  '::SnsProviders::QqWeibo',
          'weibo' => '::SnsProviders::SinaWeibo',
          'sina' =>  '::SnsProviders::SinaWeibo',
          'douban' => '::SnsProviders::Douban'
      }

      def self.call(user, sns_name = '')
        new(user,sns_name).friends
      end

      def initialize(user, sns_name)
        @user = user
        @sns_name = sns_name
      end

      def friends
        rfriends = []
        friends = sns_provider.where(:user_id => @user.id)
        oauth_users = if @sns_name.present?
                        ::Users::Oauth.includes(:user).where(:sns_name => @sns_name)
                      else
                        ::Users::Oauth.includes(:user).all
                      end
        if friends.present? && oauth_users.present?
          oauth_users.each do |ouser|
            friends.each{|f| rfriends << ouser.user if (f.uid == ouser.sns_user_id) || (f.uid == ouser.provider_user_id) }
          end
          rfriends.delete_if{|i| i.id == @user.id }.uniq!
        else
          false
        end
        rfriends
      end

      def sns_provider
        return UserSnsFriend unless @sns_name.present?
        eval(SNS_FRIEND[@sns_name])
      end

    end

  end
end