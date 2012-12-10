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
  validates_presence_of :body
  validates_presence_of :user
  scope :recent, lambda { |limit| order("created_at DESC").limit(limit) }
  scope :reply_comments, lambda{|parent_id| where("parent_id = ? and deleted_at is null", parent_id)}
  scope :with_point_is, lambda {|point| where(["point = ?", point])}

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

  scope :real_comments, lambda {where("parent_id IS NULL").order("created_at DESC")}

  scope :for_event, lambda {|event_id| where(:commentable_type => 'Event', :commentable_id => event_id)}
  scope :with_votes,
    joins('LEFT OUTER JOIN `votes` ON comments.id = votes.votable_id').
    select("comments.*, count(votes.id) as votes_count").
    where('parent_id IS NULL').
    group('comments.id')

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
  
  after_create :change_commentable_id
  # Helper class method that allows you to build a comment
  # by passing a commentable object, a user_id, and comment text
  # example in readme

  #仅对commentable_type 是 Note是起作用
  def change_commentable_id
    self.update_attribute(:commentable_id, Note.find(commentable_id).app_note_id) if commentable_type == "Note"
  end
  
  #判断commentable 是否是 note
  def commentable
    commentable_type == "Note" ? note = Note.find_by_app_note_id(commentable_id) : super
  end

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

  #helper method to check if a comment has children
  def has_children?
    self.children.size > 0
  end


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
    when "Event"
      'events'
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
  def share_comment_to_weibo
    sleep 10
    oauth_comments.unshare.each do |oauth_comment|
      oauth_comment.share_to_sns
    end
  end


  #截取部分评论内容
  def share_content(url, sns_type)
    content = %Q(对#{commentable.share_name}发表了评论："#{body.to_s.strip.mb_chars[0, 70]}...#{url}"#{"（分享自 @iWine爱红酒）" unless sns_type == "douban"})
  end

  def get_sns_comments
    begin
      reply_list = []
      oauth_comments.each do |oauth_comment|
        reply_list << oauth_comment.get_sns_reply
      end 
      reply_list = reply_list.compact.flatten
      if reply_list.present?
        reply_list_final = reply_list.sort_by{|item| item[:created_at]}
        return reply_list_final
      else
        return nil
      end
    rescue NoMethodError => e
      Rails.logger.error e
    end
  end
  
end
