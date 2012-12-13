#encoing: utf-8
module Service
  module SinaWeiboService

    # usage: access_token = Users::Oauth.find(7).tokens
    # Service::SinaWeiboService.post("content", access_token, :image_url => "/upload/test.png" )

    def self.post(content, access_token, options = {})
      ::SnsProviders::SinaWeibo::Poster.perform(content, access_token, options)
    end

  end
end