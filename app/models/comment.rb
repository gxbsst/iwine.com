# -*- coding: utf-8 -*-
class Comment < ActiveRecord::Base
  default_scope where('deleted_at IS NULL')
  scope :with_wine_follows, where(:commentable_type => "Wines::Detail", :do => "follow")

  acts_as_nested_set :scope => [:commentable_id, :commentable_type]
  validates_presence_of :body
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

  scope :real_comments, lambda {where(" do = 'comment' ")}
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

end
