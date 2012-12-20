# encoding: utf-8
module SnsProviders
  class Tqq2 < ::UserSnsFriend

    SNS_NAME = 'qq'

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
        if @options.has_key? :image_url
          upload_with_image
        else
          upload_with_text
        end
      end

      private

      def client
        @client ||= ::Oauth::Tqq2.load(@access_token)
      end

      def upload_with_image
        client.post(post_image_url, {:content => @content, :pic_url => "#{QQ_PIC_URL}#{image_url}", :clientip => ip}).body
      end

      def upload_with_text
        @response =  client.add_status(@content, :clientip => ip).body
      end


      def image_url
        @options[:image_url]
      end

      def post_image_url
        'http://open.t.qq.com/api/t/add_pic_url'
      end

      def post_text_url
        "/statuses/update.json"
      end

      def ip
        "222.73.181.116"
      end

    end

  end

end
