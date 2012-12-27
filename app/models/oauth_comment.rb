class OauthComment < ActiveRecord::Base
  attr_accessible :comment_id, :sns_type, :sns_comment_id, :body, :error_info, :sns_user_id, :user_id, :image_url, :status, :ip_address
  belongs_to :comment
  belongs_to :user
  scope :unshare, where("status = #{APP_DATA['oauth_comments']['status']['no_share']}")

  #将int转化为ip地址
  def inet_ntoa
    [ip_address].pack("N").unpack("C*").join "."
  end

  #检测oauth_comment是不是尚未同步到第三方
  def is_unshare?
    status.to_i == APP_DATA['oauth_comments']['status']['no_share']
  end

  def get_sns_reply
  	reply_list = search_comments
    return reply_list
  end
  
  #comment_id 可以是 comment.id 或者 note.app_note_id
  def self.build_delay_oauth_comment(sns_type, user, ip_address, image_url, body, comment_id)
    oauth_user = user.oauths.oauth_binding.where('sns_name = ?', sns_type).first
    if oauth_user #检测用户是否绑定
      oauth_comment = user.oauth_comments.new(:sns_type => sns_type,
                              :comment_id => comment_id,
                              :body => body,
                              :sns_user_id => oauth_user.sns_user_id,
                              :ip_address => inet_aton(ip_address))
      oauth_comment.image_url = image_url
      oauth_comment.save
      oauth_comment.delay.share_to_sns
    end
  end

  def share_to_sns
    begin
      if user.check_oauth?(sns_type) && is_unshare?
      	case sns_type
      	when 'qq'
      	  send_qq
      	when 'weibo'
      	  send_weibo
      	when 'douban'
      	  send_douban
      	end
      end
    rescue OAuth2::Error => e
      failure_share e
    end
  end

  def search_comments
    begin
      if user.check_oauth?(sns_type) && sns_comment_id #检测是否被同步，是否分享成功
        case sns_type
        when 'qq'
          qq_comments 
        when 'weibo'
          weibo_comments
        when 'douban'
          douban_comments
        end
      end
    rescue Exception => e
      Rails.logger.error e
    end
  end

  #将ip地址转化为整数
  def self.inet_aton(ip)
    ip.split(/\./).map{|c| c.to_i}.pack("C*").unpack("N").first
  end
  private
  #获取回复

  def weibo_comments
    oauth_weibo = user.oauths.oauth_binding.where('sns_name = ?', 'weibo').first
    access_token = user.init_client('weibo', oauth_weibo.access_token)
    response = access_token.get("/2/comments/show.json", :params => {:id => sns_comment_id}).body
    data = JSON.parse response
    return nil if data['comments'].blank?
    reply_list = []
    data['comments'].each do |reply|
      reply_hash = {:type => 'weibo'}
      reply_list << reply_hash.merge({
        :name => reply['user']['screen_name'],
        :created_at => Time.parse(reply['created_at']).to_i,
        :content => reply['text'],
        :head_url => reply['user']['profile_image_url']
      })
    end
    return reply_list
  end
  
  def qq_comments
    qq_client = user.oauth_client('qq')
    response = qq_client.get("http://open.t.qq.com/api/t/re_list?flag=1&rootid=#{sns_comment_id}").body
    data = JSON.parse response
    return nil if data['data'].blank?
    reply_list = []
    data['data']['info'].each do |reply|
      reply_hash = {:type => 'qq'}
      reply_list << reply_hash.merge({
        :name => reply['nick'],
        :created_at => reply['timestamp'],
        :content => reply['text'],
        :head_url => "#{reply['head']}/30"
      })
    end
    return reply_list
  end
  
  #得到[{:type => '', :name => ''}, {:type = '', :name => ''}]
  #JSON::ParserError 对应广播被删除得情况
  def douban_comments
    begin
      douban_client = user.oauth_client('douban')
      response = douban_client.get("#{sns_comment_id}/comments", "alt" => "json").body
      data = JSON.parse response
      return nil if data['entry'].blank?
      reply_list = []
      data['entry'].each do |reply|
        reply_hash = {:type => 'douban'}
        head_url = nil
        head_url = reply['author']['link'].each{|link|}
        reply['author']['link'].each do |link| 
          head_url = link['@href'] if link.has_value?('icon') #获取用户头像
        end
        reply_list << reply_hash.merge({
          :content => reply['content']['$t'],
          :head_url => head_url,
          :created_at => Time.parse(reply['published']['$t']).to_i,
          :name => reply['author']['name']['$t']
        })
      end
      return reply_list
    rescue JSON::ParserError => e
      return nil
    end
  end

  #发送评论
  def send_weibo
    #oauth_user = user.oauths.oauth_binding.where('sns_name = ?', 'weibo').first
    #if image_url
    #  #调用新浪发送图片的api
    #  conn = Faraday.new(:url => "https://upload.api.weibo.com"){|f| f.request(:multipart); f.adapter(:net_http)}
    #  response = conn.post('/2/statuses/upload.json',
    #                        :access_token => oauth_weibo.access_token,
    #                        :status => body,
    #                        :pic => Faraday::UploadIO.new("#{Rails.root.join('public')}#{image_url}", 'image/jpeg')).body
    #else
    #  access_token = user.init_client('weibo', oauth_weibo.access_token)
    #  response = access_token.post("/statuses/update.json", :params => {:status => body}).body
    #end
    oauth_user = user.oauths.oauth_binding.where('sns_name = ?', 'weibo').first
    options = image_url ? {:image_url => image_url} : {}
    response = ::SnsProviders::SinaWeibo::Poster.perform(body, oauth_user.tokens, options)
    #处理结果信息
    result_data = JSON.parse response
    if result_data['error']
      failure_share "error:#{result_data['error']},error_code:#{result_data['error_code']},request:#{result_data['request']}"
    else
      success_share result_data['id']
    end
  end

  def send_qq
    #qq_client = user.oauth_client('qq')
    ##TODO 修改ip
    #if image_url
    #  # :pic_url =>  "http://patrickdev.sidways.com#{image_url}",
    #  response = qq_client.post("http://open.t.qq.com/api/t/add_pic_url",
    #  	             {:content => body,
    #                  :pic_url => "#{QQ_PIC_URL}#{image_url}",
    #  	              :clientip => inet_ntoa}).body
    #else
   	#  response = qq_client.add_status(body, :clientip => inet_ntoa).body
   	#end
    oauth_user = user.oauths.oauth_binding.where('sns_name = ?', 'qq').first
    options = image_url ? {:image_url => image_url} : {}
    response = ::SnsProviders::Tqq2::Poster.perform(body, oauth_user.qq_tokens, options)

   	#处理结果信息
   	result_data = JSON.parse response
   	if result_data['msg'] == 'ok'
      success_share result_data['data']['id']
    else
      failure_share "errcode:#{result_data['errcode']}, msg:#{result_data['msg']},ret:#{result_data['ret']}"
    end  
  end

  def send_douban
    #douban_client = user.oauth_client('douban')
    #response = douban_client.add_douban_status(body)

    oauth_user = user.oauths.oauth_binding.where('sns_name = ?', 'douban').first
    response = ::SnsProviders::Douban::Poster.perform(body, oauth_user.tokens)

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
