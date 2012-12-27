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
      #   { :access_token => access_token, :openid => openid }
      #   or oauth_user.tokens
      # options = {:image_url => '/upload/test.png'} // 如果需要传图片

      def self.perform(content, access_token = {}, options = {})
        new(content, access_token, options).update
      end

      def initialize(content, access_token, options)
        @content = content
        @access_token = access_token
        @options = options
        @openid = access_token[:openid]
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
        @client ||= SnsProviders::HelperMethods::Oauth::Tqq2.load(@access_token).client
      end

      def upload_with_image
        client.post(post_image_url,
                    :body => {:content => @content, :pic_url => "#{QQ_PIC_URL}#{image_url}"},
                    :params => request_params).body
      end

      def upload_with_text

        client.post(post_text_url, :body => {:content => @content}, :params => request_params).body
      end


      def image_url
        @options[:image_url]
      end

      def post_image_url
        'http://open.t.qq.com/api/t/add_pic_url'
      end

      def post_text_url
        "https://open.t.qq.com/api/t/add"
      end

      def ip
        #"199.68.199.136"
        "222.73.181.116"
      end

      def request_params
        {:access_token => @access_token,
         :format => "json",
         :oauth_version => "2.a",
         :openid => @openid,
         :oauth_consumer_key => TQQ2['key'],
         :clientip => ip}
      end

    end

    class Getter

      attr_accessor :url,:params, :tqq2

      def self.get_reply(access_token, params = {}, &block)
        # api man: http://wiki.open.t.qq.com/index.php/API文档/微博相关/获取单条微博的转发或点评列表
        options = {:flag => 2, :pageflag => 0, :pagetime => 0, :reqnum => 20, :twitterid => 0 }
        new('api/t/re_list', access_token, params.merge(options), &block).execute
      end

      def initialize(url, access_token, params = {}, &block)
        @url = url
        @params = params
        @block = block
        @tqq2 ||= SnsProviders::HelperMethods::Oauth::Tqq2.load(access_token)
      end

      def execute
        result = tqq2.client.get(url, :params => params.merge(tqq2.params)).body
        @block.call(result) if @block
        result
      end

    end

  end

end
