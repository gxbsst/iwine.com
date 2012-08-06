module SNS
  
  module Sina
    def friends(options = {})
      # tokens = current_user.oauths.oauth_record('sina').tokens
      # client = OauthChina::Sina.load(tokens)
      followers_json = self.get("http://api.t.sina.com.cn/statuses/followers.json").body
      data = JSON.parse followers_json
      list = []
      unless data["error_code"].present?
        data.each do |friend|
          list.push( {
            :sns_user_id => friend['id'].to_i,
            :username => friend['screen_name'],
            :avatar => friend['profile_image_url']
          })
        end
      end
      list
    end

    def possible_local_friends(user_oauth)
      sns_user_ids = []
      friends_hash = {}

      friends.each do |friend|
        sns_user_ids.push friend[:sns_user_id]
        friends_hash[ friend[:sns_user_id] ] = friend
      end
      local_user = Users::Oauth.all :conditions => { 'sns_name' => 'sina', 'sns_user_id' => sns_user_ids }

      local_user.each do |friend|
        friend.sns_info = friends_hash[friend.sns_user_id.to_i]
      end

      local_user
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

    def friends(user_oauth)
      data = self.get("http://open.t.qq.com/api/friends/mutual_list?name=#{user_oauth.sns_user_id}").body
      data = JSON.parse data
      list = []

      data['data']['info'].each do |friend|
        list.push( {
          :sns_user_id => friend['name'],
          :username => friend['nick'],
          :avatar => friend['headurl']
        } )
      end
      list
    end
        
    def possible_local_friends(user_oauth)
      sns_user_ids = []
      friends_hash = {}

      friends(user_oauth).each do |friend|
        sns_user_ids.push friend[:sns_user_id]
        friends_hash[ friend[:sns_user_id] ] = friend
      end
      local_user = Users::Oauth.all :conditions => { 'sns_name' => 'qq', 'sns_user_id' => sns_user_ids }

      local_user.each do |friend|
        friend.sns_info = friends_hash[friend.sns_user_id.to_i]
      end

      local_user
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
          :sns_user_id => friend['db:uid']['$t'],
          :username => friend['title'],
          :avatar => friend['link'][2]['@href']
        })
      end

      list
    end
    
    def possible_local_friends(user_oauth)
      sns_user_ids = []
      friends_hash = {}

      friends.each do |friend|
        sns_user_ids.push friend[:sns_user_id]
        friends_hash[ friend[:sns_user_id] ] = friend
      end
      local_user = Users::Oauth.all :conditions => { 'sns_name' => 'douban', 'sns_user_id' => sns_user_ids }

      local_user.each do |friend|
        friend.sns_info = friends_hash[friend.sns_user_id.to_i]
      end

      local_user
    end
    
    #重写oauth_china上的方法，将返回数据类型定义为json
    def add_douban_status(content, options = {})
      self.post("http://api.douban.com/miniblog/saying", <<-XML, {"Content-Type" =>  "application/atom+xml", "alt" => "json"})
        <?xml version='1.0' encoding='UTF-8'?>
        <entry xmlns:ns0="http://www.w3.org/2005/Atom" xmlns:db="http://www.douban.com/xmlns/">
        <content>#{content}</content>
        </entry>
        XML
    end
  end
end