# encoding: utf-8
class UserSnsFriend < ActiveRecord::Base
  include SnsProviders::HelperMethods

  # Object Value
  class Friend < ::Struct.new(:uid, :nickname, :name, :avatar); end

  attr_accessible :user_id, :avatar, :name, :nickname, :type, :uid

  belongs_to :user

  validates :user_id, :presence => true


  SNS_PROVIDER = {
      'qq' => '::SnsProviders::HelperMethods::Oauth::Tqq2',
      'weibo' => '::SnsProviders::HelperMethods::Oauth::Sina',
      'sina' => '::SnsProviders::HelperMethods::Oauth::Sina',
      'douban' => '::OauthChina::Douban'
  }
  SNS_FRIEND = {
      'qq' => '::SnsProviders::Tqq2',
      'weibo' => '::SnsProviders::SinaWeibo',
      'sina' =>  '::SnsProviders::SinaWeibo',
      'douban' => 'SnsProviders::Douban'
  }

  class << self

    def sync
      ::SnsProviders::Tqq2.sync
      ::SnsProviders::QqWeibo.sync
      ::SnsProviders::SinaWeibo.sync
      ::SnsProviders::Douban.sync
    end

    def sync_one(user, oauth_user)
      return false unless SNS_PROVIDER.has_key? oauth_user.sns_name
      friends = fetch_friends(oauth_user)
      if friends.present?
        friends.each {|friend| create_one_friend(user, friend, oauth_user)}
      else
        false
      end
    end

    def create_one_friend(user, friend, oauth_user)
      friend_item = eval(SNS_FRIEND[oauth_user.sns_name]).where(:user_id => user.id, :uid => friend.uid).first_or_initialize(
          :user_id => user.id,
          :uid => friend.uid,
          :nickname => friend.nickname,
          :name => friend.name,
          :avatar => friend.avatar
      )
      friend_item.save
    end

    def create_friend(oauth_user)
      user = oauth_user.user
      friends = fetch_friends(oauth_user)
      if friends.present?
        friends.each do |friend|
          create_one_friend(user, friend, oauth_user)
        end
      end
    end

    def fetch_friends(oauth_user)
      token = oauth_user.sns_name == 'qq' ? oauth_user.qq_tokens : oauth_user.tokens
      client = eval(SNS_PROVIDER[oauth_user.sns_name]).load( token )
      client.get_friends(oauth_user.provider_user_id)
    end

  end

end



