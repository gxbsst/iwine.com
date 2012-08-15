class OauthComment < ActiveRecord::Base
  attr_accessible :comment_id, :sns_type, :sns_comment_id, :body, :error_info, :sns_user_id, :user_id, :image_url, :status
  belongs_to :comment
  belongs_to :user
  scope :unshare, where("status = #{APP_DATA['oauth_comments']['status']['no_share']}")

  def sns_comments
  	comment.get_sns_comments(self)
  end

  def share_to_sns
  	case sns_type
  	when 'qq'
  	  send_qq
  	when 'weibo'
  	  send_weibo
  	when 'douban'
  	  send_douban
  	end
  end

  
  private

  def send_weibo
    oauth_weibo = user.oauths.oauth_binding.where('sns_name = ?', 'weibo').first
    if image_url
      #调用新浪发送图片的api
      conn = Faraday.new(:url => "https://upload.api.weibo.com"){|f| f.request(:multipart); f.adapter(:net_http)}
      response = conn.post('/2/statuses/upload.json', 
                            :access_token => oauth_weibo.access_token, 
                            :status => body, 
                            :pic => Faraday::UploadIO.new("#{Rails.root.join('public')}#{image_url}", 'image/jpeg')).body
    else
      access_token = user.init_client('weibo', oauth_weibo.access_token)
      response = access_token.post("/statuses/update.json", :params => {:status => body}).body
    end
    #处理结果信息
    result_data = JSON.parse response
    if result_data['error']
      failure_share "error:#{result_data['error']},error_code:#{result_data['error_code']},request:#{result_data['request']}"
    else
      success_share result_data['id']
    end
  end

  def send_qq
    qq_client = user.oauth_client('qq')
    #TODO 修改ip
    if image_url
      response = qq_client.post(" http://open.t.qq.com/api/t/add_pic_url", 
      	             {:content => body, 
      	              :pic_url =>  "http://patrickdev.sidways.com#{image_url}", 
      	              :clientip => "180.168.220.98"}).body
    else
   	  response = qq_client.add_status(body, :clientip => "180.168.220.98").body
   	end
   	#处理结果信息
   	result_data = JSON.parse response
   	if result_data['msg'] == 'ok'
      success_share result_data['data']['id']
    else
      failure_share "errcode:#{result_data['errcode']}, msg:#{result_data['msg']},ret:#{result_data['ret']}"
    end  
  end

  def send_douban
    douban_client = user.oauth_client('douban')
    response = douban_client.add_douban_status('')
    if response.code > "202" #豆瓣的文档，大于202则为错误代码
      failure_share(response.msg)
    else
      result_data = JSON.parse response.body
      success_share result_data['id']['$t']
    end
  end

  
  def success_share(sns_comment_id)
  	self.sns_comment_id = sns_comment_id
  	self.status = APP_DATA['oauth_comments']['status']['success']
  	self.save
  end
  
  def failure_share(error_info)
  	self.error_info = error_info
  	self.status = APP_DATA['oauth_comments']['status']['failure']
  	self.save
  end
end
