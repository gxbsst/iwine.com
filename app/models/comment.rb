# -*- coding: utf-8 -*-
class Comment < ActiveRecord::Base

  counts :votes_count => {:with => "ActsAsVotable::Vote",
                          :receiver => lambda {|vote| vote.votable },
                          :increment => {:on => :create,  :if => lambda {|vote| vote.votable_type == "Comment" && vote.vote_flag == true}},
                          :decrement => {:on => :destroy, :if => lambda {|vote| vote.votable_type == "Comment" && vote.vote_flag == true}}
                          }

  default_scope where('deleted_at IS NULL')
  scope :with_wine_follows, where(:commentable_type => "Wines::Detail", :do => "follow")

  acts_as_nested_set :scope => [:commentable_id, :commentable_type]
  validates_presence_of :body, :if => :is_comment?
  validates_presence_of :user
  scope :recent, lambda { |limit| order("created_at DESC").limit(limit) }
  scope :with_point_is, lambda {|point| where(["point = ?", point])}

  # NOTE: install the acts_as_votable plugin if you
  # want user to vote on the quality of comments.
  # acts_as_voteable
  acts_as_votable

  # 保存分享信息， 如新浪微博等
  store_configurable
  belongs_to :commentable, :polymorphic => true
  has_many :oauth_comments

  # NOTE: Comments belong to a user
  belongs_to :user

  # Helper class method that allows you to build a comment
  # by passing a commentable object, a user_id, and comment text
  # example in readme
  def self.build_from(obj, user_id, comment, options = { } )
    c = self.new
    c.commentable_id = obj.id
    c.commentable_type = obj.class.base_class.name
    c.body = comment
    c.user_id = user_id
    # opstions
    unless options.blank?
      options.each do |k, v|
        c.send("#{k}=", v)
      end
    end
    c
  end

  # 如果是关注，允许body为空
  def is_comment?
    self.do == 'comment'
  end
  #helper method to check if a comment has children
  def has_children?
    self.children.size > 0
  end

  # Helper class method to lookup all comments assigned
  # to all commentable types for a given user.
  scope :find_comments_by_user, lambda { |user|
    where(:user_id => user.id).order('created_at DESC')
  }

  # Helper class method to look up all comments for
  # commentable class name and commentable id.
  scope :find_comments_for_commentable, lambda { |commentable_str, commentable_id|
    where(:commentable_type => commentable_str.to_s, :commentable_id => commentable_id).order('created_at DESC')
  }

  scope :real_comments, lambda {where(" do = 'comment' AND parent_id IS NULL")}
  # Helper class method to look up a commentable object
  # given the commentable class name and id
  def self.find_commentable(commentable_str, commentable_id)
    commentable_str.constantize.find(commentable_id)
  end

  def get_commentable_path
    path = case commentable_type
    when "Wines::Detail"
      "wines"
    when "Winery"
      "wineries"
    when "User"
      "users"
    end
    return path
  end

  def children_and_order(order = "created_at DESC")
    Comment.where(["parent_id = ?", id]).order(order)
  end

  def self.get_comments(commentable, option = {})
    commentable.comments.all(:include => [:user],
                             :joins => "LEFT OUTER JOIN `votes` ON comments.id = votes.votable_id",
                             :select => "comments.*, count(votes.id) as votes_count",
                             :conditions => ["parent_id is null and do = 'comment'"], :group => "comments.id",
                             :order => "votes_count DESC, created_at DESC", :limit => option[:limit] )
  end

  # COUNTER
  # comments_count
  def comments_counter_should_increment?
    if self.do == "comment" && self.parent_id.blank?
      true
    end
  end

  def comments_counter_should_decrement?
    if self.do == "comment" && self.parent_id.blank? && !deleted_at.blank?
      true
    end
  end

  # increment
  def counter_should_increment_for(commentable_type)
    if self.commentable_type == commentable_type && self.comments_counter_should_increment?
      true
    end
  end

  # decrement
  def counter_should_decrement_for(commentable_type)
    if self.commentable_type == commentable_type && self.comments_counter_should_decrement?
      true
    end
  end

  # followers_count
  def follower_counter_should_increment?
    if self.do == "follow" && self.parent_id.nil?
      true
    end
  end

  def follower_counter_should_decrement?
    if self.do == "follow" && self.parent_id.blank? && !deleted_at.blank?
      true
    end
  end

  # increment
  def followers_counter_should_increment_for(commentable_type)
    if self.commentable_type == commentable_type && self.follower_counter_should_increment?
      true
    end
  end

  # decrement
  def followers_counter_should_decrement_for(commentable_type)
    if self.commentable_type == commentable_type && self.follower_counter_should_decrement?
      true
    end
  end
  
  #分享评论到第三方网站
  def share_comment_to_weibo(weibo_type)
    if parent_id.nil? && weibo_type.present?
      sleep 10
      share_comment(weibo_type)
    end
  end

  
  def send_weibo(content)
    oauth_weibo = user.oauths.oauth_binding.where('sns_name = ?', 'weibo').first
    access_token = user.init_client('weibo', oauth_weibo.access_token)
    response = access_token.post("https://upload.api.weibo.com/2/statuses/upload.json", :params => {:status => content, :pic => Photo.first.image}).body
    Rails.logger.info "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ #{response}"
    new_oauth_comment(JSON.parse(response)['id'], 'weibo')
  end

  def send_qq(content)
    qq_client = user.oauth_client('qq')
    #TODO 修改ip
    response = qq_client.add_status(content, :clientip => "180.168.220.98").body
    new_oauth_comment(JSON.parse(response)['data']['id'], 'qq')
  end

  def send_douban(content)
    douban_client = user.oauth_client('douban')
    response = douban_client.add_douban_status(content).body
    new_oauth_comment(JSON.parse(response)['id']['$t'], 'douban')
  end
  
  #检查并发送信息到对应网站
  def check_oauth(content, weibo_type)
    sns_name = user.oauths.oauth_binding.map{|oauth| oauth.sns_name}#找到用户已绑定得网站
    weibo_type.each do |w|
      if w == "qq" && sns_name.include?("qq")
        send_qq(content)
      elsif w == "weibo" && sns_name.include?("weibo")
        send_weibo(content)
      elsif w ==  "douban" && sns_name.include?("douban")
        send_douban(content)
      end
    end
  end

  def share_comment(weibo_type)
    #处理要发送的内容
    short_content = cut_content(body)
    #检查并发送微博
    check_oauth(short_content, weibo_type)
  end

  #截取部分评论内容
  def cut_content(content)
    #TODO 修改发送内容
    "测试分享内容到微博#{Time.now}"
  end

  def new_oauth_comment(sns_id, type)
    oauth_comments.create(:sns_type => type, :sns_id => sns_id)
  end

  def get_sns_comments(oauth_comment)
    case oauth_comment.sns_type
    when 'douban'
      douban_comments(oauth_comment.sns_id)
    when 'qq'
      qq_comments(oauth_comment.sns_id)
    when 'weibo'
      weibo_comments(oauth_comment.sns_id)
    end
  end

  def weibo_comments(uid)
    oauth_weibo = user.oauths.oauth_binding.where('sns_name = ?', 'weibo').first
    access_token = user.init_client('weibo', oauth_weibo.access_token)
    response = access_token.get("/2/comments/show.json", :params => {:id => uid}).body
    data = JSON.parse response
    comment_arr = []
    data['comments'].each{|comment| comment_arr << comment['text']}
    return comment_arr
  end
  
  def qq_comments(uid)
    qq_client = user.oauth_client('qq')
    response = qq_client.get("http://open.t.qq.com/api/t/re_list?flag=1&rootid=#{uid}").body
    data = JSON.parse response
    comment_arr = []
    data['data']['info'].each{|comment| comment_arr << comment['text']} if data['msg'] == 'ok'
    return comment_arr
  end

  def douban_comments(uid)
    douban_client = user.oauth_client('douban')
    response = douban_client.get("#{uid}/comments", "alt" => "json").body
    data = JSON.parse response
    comment_arr = []
    data['entry'].each{|comment| comment_arr << comment['content']['$t']}
    return comment_arr
  end
  
end
