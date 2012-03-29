module SNS
  module Sina
    def friends(options = {})
      # tokens = current_user.oauths.oauth_record('sina').tokens
      # client = OauthChina::Sina.load(tokens)
      followers_json = self.get("http://api.t.sina.com.cn/statuses/followers.json").body
      JSON.parse(followers_json)
    end
  end
end