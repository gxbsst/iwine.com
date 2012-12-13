#encoing: utf-8
module Service
  module DoubanService

    # usage: access_token = Users::Oauth.find(7).tokens
    # Service::DoubanService.post("content", access_token)
    # 豆瓣不能上传图片
    def self.post(content, access_token, options = {})
      ::SnsProviders::Douban::Poster.perform(content, access_token, options)
    end

  end
end