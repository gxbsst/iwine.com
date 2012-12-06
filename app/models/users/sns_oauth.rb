#encoding: utf-8
require 'oauth2'
module Users
  module SnsOauth
    #oauth2找好友
    def init_client(type, token)
      client = case type
                 when 'weibo'
                   OAuth2::Client.new(OAUTH_DATA['weibo']['key'], OAUTH_DATA['weibo']['secret'],{
                       :site => "https://api.weibo.com",
                       :authorize_url => "/oauth2/authorize",
                       :token_url => "/oauth2/access_token"
                   })
               end
      access_token = OAuth2::AccessToken.new(client, token)
      access_token.options[:mode] = :query
      access_token.options[:param_name] = 'access_token'
      access_token
    end

    def weibo_friends(type, token, uid)
      #发送请求获得好友
      access_token = init_client(type, token)

      response = access_token.get('/2/friendships/followers.json', :params => {:uid => uid}).parsed

      follower_list = []
      response['users'].each do |follower|
        follower_list.push( {
          :sns_user_id => follower['id'],
          :username => follower['screen_name'],
          :avatar => follower['profile_image_url']
        })
      end

      search_friend(follower_list)
      #查找好友
      
    end

    def search_friend(followers)
      sns_user_ids = []
      follower_hash = {}
      followers.each do |f|
        sns_user_ids << f[:sns_user_id]
        follower_hash[f[:sns_user_id]] = f
      end

      oauth_users = Users::Oauth.oauth_binding.where(" sns_name = 'weibo' and sns_user_id in (?) ", sns_user_ids)

      oauth_users.each do |oauth_user|
        oauth_user.sns_info = follower_hash[oauth_user.sns_user_id.to_i]
      end
      return oauth_users
    end

  end
end