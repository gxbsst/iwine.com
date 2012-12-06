# encoding: utf-8
class UserSnsFriend < ActiveRecord::Base
  include SnsProviders::HelperMethods

  # Object Value
  class Friend < ::Struct.new(:uid, :nickname, :name, :avatar); end

  attr_accessible :user_id, :avatar, :name, :nickname, :type, :uid
  validates :user_id, :presence => true


  SNS_PROVIDER = {
      'qq' => 'OauthChina::Qq',
      'weibo' => '::SnsProviders::HelperMethods::Oauth::Sina',
      'sina' => '::SnsProviders::HelperMethods::Oauth::Sina',
      'douban' => '::OauthChina::Douban'
  }
  SNS_FRIEND = {
      'qq' => '::SnsProviders::QqWeibo',
      'weibo' => '::SnsProviders::SinaWeibo',
      'sina' =>  '::SnsProviders::SinaWeibo',
      'douban' => 'SnsProviders::Douban'
  }


  class << self
    def sync
      ::SnsProviders::QqWeibo.sync
      ::SnsProviders::SinaWeibo.sync
      ::SnsProviders::Douban.sync
    end

    def create_friend(oauth_user)
      user = oauth_user.user
      friends = fetch_friends(user, oauth_user)
      if friends.present?
        friends.each do |f|
          friend = eval(SNS_FRIEND[oauth_user.sns_name]).where(:user_id => user.id, :uid => f.uid).first_or_initialize(
              :user_id => user.id,
              :uid => f.uid,
              :nickname => f.nickname,
              :name => f.name,
              :avatar => f.avatar
          )
          friend.save
        end
      end
    end

    def fetch_friends(user, oauth_user)
      client = eval(SNS_PROVIDER[oauth_user.sns_name]).load( oauth_user.tokens )
      friends = client.get_friends(oauth_user.sns_user_id)
    end
  end
end



