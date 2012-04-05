module SNS
  
  module Sina
    def friends(options = {})
      # tokens = current_user.oauths.oauth_record('sina').tokens
      # client = OauthChina::Sina.load(tokens)
      followers_json = self.get("http://api.t.sina.com.cn/statuses/followers.json").body
      JSON.parse(followers_json)
    end

    def me
      user = self.get("http://api.t.sina.com.cn/account/verify_credentials.json").body
      JSON.parse user
    end

    def user_id
      me['id']
    end

  end

  module Qq

    def me
      user = self.get('http://open.t.qq.com/api/user/info').body
      JSON.parse user
    end

    def user_id
      me['data']['name']
    end

    def friends
      friends = self.get('http://open.t.qq.com/api/friends/mutual_list').body
      friends = JSON.parse(friends)
      friends['data']['info']
    end

  end


  module Douban 

    def me
      user = self.get('http://api.douban.com/people/@me').body
      XML.parse user
    end

    def user_id
      me['data']['name']
    end

    def friends
      friends = self.get('http://open.t.qq.com/api/friends/mutual_list').body
      XML.parse(friends)
    end

  end
end