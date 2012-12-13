#encoing: utf-8
module Service
  module QqWeiboService

    # usage: access_token = Users::Oauth.find(7).tokens
    # Service::QqWeiboService.post("content", access_token, :image_url => "/upload/test.png" )
    def self.post(content, access_token, options = {})
      ::SnsProviders::QqWeibo::Poster.perform(content, access_token, options)
    end

  end
end