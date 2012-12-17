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

    class Poster
      # params
      # access_token
      #   { :access_token => access_token, :access_token_secret => refresh_token }
      #   or oauth_user.tokens
      # options = {:image_url => '/upload/test.png'} // 如果需要传图片

      def self.perform(content, access_token = {}, options = {})
        new(content, access_token, options).update
      end

      def initialize(content, access_token, options)
        @content = content
        @access_token = access_token
        @options = options
      end

      def update
        upload_with_text
      end

      private

      def client
        @client ||= ::OauthChina::Douban.load(@access_token)
      end

      def upload_with_text
        @response =  client.add_douban_status(@content)
        #@response =  client.add_douban_status(@content).body
      end

    end

  end
end