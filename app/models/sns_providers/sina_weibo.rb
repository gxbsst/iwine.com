# encoding: utf-8
  class ::SnsProviders::SinaWeibo < ::UserSnsFriend

    SNS_NAME = 'weibo'

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
      # access_token = {:access_token => access_token}
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
        @client ||= SnsProviders::HelperMethods::Oauth::Sina.load(@access_token).client
      end

      def upload_with_image
        conn = Faraday.new(:url => "https://upload.api.weibo.com"){|f| f.request(:multipart); f.adapter(:net_http)}
        @response = conn.post(post_image_url, :access_token => @access_token[:access_token], :status => @content, :pic => image ).body
      end

      def upload_with_text
        @response =  client.post(post_text_url, :params => {:status => @content}).body
      end

      def image
        Faraday::UploadIO.new("#{Rails.root.join('public')}#{@options[:image_url]}", 'image/jpeg')
      end

      def post_image_url
        '/2/statuses/upload.json'
      end

      def post_text_url
        "/statuses/update.json"
      end

    end

  end

