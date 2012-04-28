# -*- coding: utf-8 -*-
class Wines::Detail < ActiveRecord::Base
  paginates_per 10

  include Wines::WineSupport
  acts_as_commentable

  belongs_to :wine
  has_many :comments, :class_name => "Comment", :foreign_key => 'commentable_id', :include => [:user], :conditions => {:commentable_type => self.to_s }
  #  has_many :good_comments, :foreign_key => 'wine_detail_id', :class_name => 'Wines::Comment', :order => 'good_hit DESC, id DESC', :limit => 5, :include => [:user_good_hit]
  has_one :statistic, :foreign_key => 'wine_detail_id'
  has_one :cover, :class_name => 'Photo',  :foreign_key => 'business_id', :conditions => { :is_cover => true, :owner_type => OWNER_TYPE_WINE }
  has_many :photos, :class_name => 'Photo',  :foreign_key => 'business_id', :limit => 5, :order => 'created_at DESC', :conditions => { :owner_type => OWNER_TYPE_WINE }
  has_many :prices, :class_name => "Price", :foreign_key => "wine_detail_id"
  has_many :variety_percentages, :class_name => 'VarietyPercentage', :foreign_key => 'wine_detail_id', :dependent => :destroy
  belongs_to :audit_log, :class_name => "AuditLog", :foreign_key => "audit_id"

  def comment( user_id )
    Wines::Comment.find_by_user_id user_id
  end

  def best_comments( limit = 5 )
    # Wines::Comment.find(:all, :include => [:user, :avatar, :user_good_hit], :limit => limit, :conditions => ["wine_detail_id = ?", id])
  end

  def cname
    year.to_s + wine.name_zh
  end

  def ename
    year.to_s + wine.origin_name
  end

  def name
    cname + ename
  end

  def other_cn_name
    wine.other_cn_name
  end

  def get_region_path
    region = Wines::RegionTree.find( wine.region_tree_id )
    parent = region.parent
    path = []
    until parent == nil
      path << parent
      parent = parent.parent
    end
    path.reverse!
  end

  def get_region_path_html( symbol = " > " )
    get_region_path.reverse!.collect { |region| region.name_en + '/' + region.name_zh }.join( symbol )
  end

  def drinkable
    drinkable_begin.to_s + ' - ' + drinkable_end.to_s
  end

  # 当前用户关注记录
  def current_user_follow(user_object)
    Comment.where(["commentable_type = ? AND do = ? AND user_id = ?", "Wines::Detail", "follow", user_object.id])
  end

  # 是否已经关注
  def is_followed? user_object
    comment = Comment.where(["commentable_type = ? AND do = ? AND user_id = ?", "Wines::Detail", "follow", user_object.id])
    return comment.blank? ? false : true
  end
end
