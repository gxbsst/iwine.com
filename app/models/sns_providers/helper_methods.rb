#encoding: utf-8
module SnsProviders
  module HelperMethods

    # QQ weibo
    ::OauthChina::Qq.class_eval do

      def friends_url(name)
        "http://open.t.qq.com/api/friends/mutual_list?fopenid=#{name}"
      end

      def get_friends(name)
        friends = []
        begin
          data = JSON.parse self.get(friends_url(name)).body
          f_info = data['data']['info']
          if f_info.present?
            f_info.each do |i|
              friends << ::UserSnsFriend::Friend.new( i['openid'], i['nick'], i['name'], i['headurl'])
            end
          end
        rescue
          true
        end
        friends
      end
    end

    # Douban

    ::OauthChina::Douban.class_eval do

      def friends_url(name)
        "http://api.douban.com/people/#{name}/contacts?alt=json"
      end

      def get_friends(name)
        friends = []
        begin
          data = JSON.parse self.get(friends_url(name)).body
          f_info = data['entry']
          if f_info.present?
            f_info.each do |i|
              friends << ::UserSnsFriend::Friend.new( i['db:uid']['$t'], i['title'], i['title'], i['link'][2]['@href'])
            end
          end
        rescue
          puts name
          true
        end
        friends
      end

    end

    # 使用Oauth2， weibo Oauth第一代已经不能用
    require 'oauth2'
    module Oauth
      class Sina

        include ::Users::SnsOauth

        def self.load(auth_access_token)
          new(auth_access_token[:access_token])
        end

        def initialize(auth_access_token)
          @access_object = init_client('weibo', auth_access_token)
        end

        def friends_url(name)
          '/2/friendships/friends/bilateral.json'
        end

        def get_friends(name)
          friends = []
          begin
            data = @access_object.get(friends_url(name), :params => {:uid => name, :count => 200}).parsed
            f_info = data['users']
            f_info.each {|i| friends << ::UserSnsFriend::Friend.new( i['id'], i['screen_name'], i['name'], i['profile_image_url']) } if f_info.present?
          rescue
            Rails.logger.info "Access Token is Expired"
            #puts name
            #true
          end
          friends
        end

        def client
          @access_object
        end

      end
    end


    module Oauth
      class Tqq2

        def self.load(auth_access_token)
          new(auth_access_token)  # with access_token && openid
        end

        def initialize(auth_access_token)
          @acces_token = auth_access_token[:access_token]
          @openid = auth_access_token[:openid]
          @access_object = access_token(@acces_token)
        end

        def friends_url
          "/api/friends/mutual_list"
        end

        def get_friends(provider_user_id)
          friends = []
          begin
            data = JSON.parse @access_object.get(friends_url, :params => params.merge(:fopenid => provider_user_id, :openid => provider_user_id)).body
            f_info = data['data']['info']
            if f_info.present?
              f_info.each do |i|
                friends << ::UserSnsFriend::Friend.new( i['openid'], i['nick'], i['name'], i['headurl'])
              end
            end
          rescue
            true
          end
          friends
        end

        def client
          @access_object
        end

        def access_token(token)
            client =  OAuth2::Client.new(TQQ2['key'], TQQ2['secret'],{
                :site           => "https://open.t.qq.com",
                :authorize_url  => "/cgi-bin/oauth2/authorize",
                :token_url      => "/cgi-bin/oauth2/access_token",
                :raise_errors  => false,
                :ssl           => {:verify => false}
            })
            access_token = OAuth2::AccessToken.new(client, token)
            access_token.options[:mode] = :query
            access_token.options[:param_name] = 'access_token'
            access_token
        end

        def params
          {:access_token => @acces_token,
           :oauth_version => '2.a',
           :oauth_consumer_key => TQQ2['key'],
           :format => 'json',
           :startindex => 0,
           :reqnum => 30,
           :openid => @openid
          }
        end

      end
    end

  end
end