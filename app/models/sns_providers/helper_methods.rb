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
          puts name
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
            puts name
            true
          end
          friends
        end

      end
    end

  end
end