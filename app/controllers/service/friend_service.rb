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

      def self.call_with_classify(user, sns_name = '')
        #binding.pry
        new(user,sns_name).friends_for_classify
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

      def friends_for_classify
        rfriends = {}
        sns_providers_map = {"SnsProviders::QqWeibo" => "tencent", "SnsProviders::Douban" => "douban", "SnsProviders::SinaWeibo" => "sina"}
        sns_providers_map.values.each {|value| rfriends[value] = []}

        friends = sns_provider.where(:user_id => @user.id)
        oauth_users = if @sns_name.present?
                        ::Users::Oauth.includes(:user).where(:sns_name => @sns_name)
                      else
                        ::Users::Oauth.includes(:user).all
                      end

        if friends.present? && oauth_users.present?
          oauth_users.each do |ouser|
            friends.each do |f|
              if ouser.user_id != @user.id
                rfriends[sns_providers_map[f.type]] << ouser.user if (f.uid == ouser.sns_user_id) || (f.uid == ouser.provider_user_id)
              end
            end
          end
          #rfriends.delete_if{|i| i.id == @user.id }.uniq!
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

    class State
      STATE_CODE = {:non_follow => 0, :following => 1, :follower => 2, :mutual_follow => 3}

      def self.run(user_a, user_b)
        new(user_a, user_b).check
      end

      def initialize(user_a, user_b)
        @user_a = user_a
        @user_b = user_b
      end

      def check
        if (@user_a.is_following @user_b.id) && (@user_b.is_following @user_a.id)
          STATE_CODE[:mutual_follow]
        elsif @user_a.is_following @user_b.id
          STATE_CODE[:following]
        elsif @user_b.is_following @user_a.id
          STATE_CODE[:follower]
        else
          STATE_CODE[:non_follow]
        end
      end

    end
  end
end