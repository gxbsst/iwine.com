module SNS
  
  module Sina
    def friends(options = {})
      # tokens = current_user.oauths.oauth_record('sina').tokens
      # client = OauthChina::Sina.load(tokens)
      followers_json = self.get("http://api.t.sina.com.cn/statuses/followers.json").body
      data = JSON.parse followers_json
      list = []

      data.each do |friend|
        list.push( {
          :sns_user_id => friend['id'],
          :username => friend['screen_name'],
          :avatar => friend['profile_image_url']
        })
      end

      list
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
      data = self.get('http://open.t.qq.com/api/friends/mutual_list').body
      data = JSON.parse data
      list = []

      data['data']['info'].each do |friend|
        list.push( {
          :sns_user_id => friend['name'],
          :username => friend['nick'],
          :avatar => friend['headurl']
        })
      end
      list
    end
  end

  module Douban 
    def me
      user = self.get('http://api.douban.com/people/%40me?alt=json').body
      JSON.parse user
    end

    def user_id
      me['db:uid']['$t']
    end

    def friends
      data = self.get('http://api.douban.com/people/'+ @sns_user_id +'/contacts?alt=json').body
      data = JSON.parse data
      list = []

      data['entry'].each do |friend|
        list.push({
          :username => friend['db:uid']['$t'],
          :nick => friend['title'],
          :avatar => friend['link'][2]['@href']
        })
      end

      list
    end
  end
end