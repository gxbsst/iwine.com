# -*- coding: utf-8 -*-

class Wines::Detail < ActiveRecord::Base
  # Count resource, e.g: photos_count, coments_count...

  counts  :photos_count   => {:with => "AuditLog",
                              :receiver => lambda {|audit_log| audit_log.logable.imageable }, 
                              :increment => {:on => :create, :if => lambda {|audit_log| audit_log.photos_counter_should_increment? && audit_log.logable.imageable_type == "Wines::Detail" }},
                              :decrement => {:on => :save,   :if => lambda {|audit_log| audit_log.photos_counter_should_decrement? && audit_log.logable.imageable_type == "Wines::Detail" }}                              
                             },              
          :comments_count => {:with => "Comment", 
                             :receiver => lambda {|comment| comment.commentable },
                             :increment => {:on => :create, :if => lambda {|comment| comment.counter_should_increment_for("Wines::Detail") }},
                             :decrement => {:on => :save,   :if => lambda {|comment| comment.counter_should_decrement_for("Wines::Detail") }}                              
                             },
         :followers_count => {:with => "Follow", 
                              :receiver => lambda {|follow| follow.followable },
                              :increment => {:on => :create, :if => lambda {|follow| follow.follow_counter_should_increment_for("Wines::Detail")}},
                              :decrement => {:on => :destroy, :if => lambda {|follow| follow.follow_counter_should_decrement_for("Wines::Detail")}}                              
                              },
          :owners_count  =>  {:with => "Users::WineCellarItem",
                              :receiver => lambda {|cellar_item| cellar_item.wine_detail},
                              :increment => {:on => :create},
                              :decrement => {:on => :destroy}
                             }                    
        

  include Common

  paginates_per 10

  include Wines::WineSupport
  acts_as_commentable

  belongs_to :wine
  has_many :comments, :class_name => "WineComment", :foreign_key => 'commentable_id', :include => [:user], :conditions => {:commentable_type => self.to_s, :parent_id => nil }
  #  has_many :good_comments, :foreign_key => 'wine_detail_id', :class_name => 'Wines::Comment', :order => 'good_hit DESC, id DESC', :limit => 5, :include => [:user_good_hit]
  # has_one :statistic, :foreign_key => 'wine_detail_id'
  has_one :item, :class_name => "Users::WineCellarItem", :foreign_key => "wine_detail_id"
  belongs_to :audit_log, :class_name => "AuditLog", :foreign_key => "audit_id"
  belongs_to :style, :foreign_key => "wine_style_id"
  has_many :covers, :as => :imageable, :class_name => "Photo", :conditions => { :photo_type => APP_DATA["photo"]["photo_type"]["cover"] }
  has_one :label, :as => :imageable, :class_name => "Photo", :conditions => { :photo_type => APP_DATA["photo"]["photo_type"]["label"] }
  has_many :photos, :as => :imageable, :class_name => "Photo"

  has_many :prices, :class_name => "Price", :foreign_key => "wine_detail_id"
  has_many :variety_percentages, :class_name => 'VarietyPercentage', :foreign_key => 'wine_detail_id', :dependent => :destroy
  has_many :special_comments, :as => :special_commentable
  has_many :follows, :as => :followable, :class_name => "WineFollow"
  has_one  :winery, :through => :wine
  scope :hot_wines, lambda { |limit| joins(:follows).
                                     includes([:wine, :covers]).
                                     select("wine_details.*, count(*) as c").
                                     group("followable_id").
                                     order("c DESC").
                                     limit(limit)
                           }
  scope :releast_detail, lambda {order("year desc").limit(1)}
  accepts_nested_attributes_for :photos, :reject_if => proc { |attributes| attributes['image'].blank? }
  accepts_nested_attributes_for :label, :reject_if => proc { |attributes| attributes['filename'].blank? }

  # Friendly Url
  extend FriendlyId
  friendly_id :pretty_url, :use => [:slugged]

  def pretty_url
    "#{wine.origin_name} #{show_year.downcase}"
  end

  # scope :with_recent_comment, joins(:comments) & ::CommenGt.recent(6)

  def comment( user_id )
    Wines::Comment.find_by_user_id user_id
  end

  def cname
    "#{show_year} #{wine.name_zh.to_s}"
  end

  def ename
    "#{show_year} #{wine.origin_name.to_s}"
  end

  def origin_name
    "#{show_year} #{wine.origin_name.to_s}"
  end
  
  def ename
    "#{show_year} #{wine.name_en.to_s}"
  end

  def name
    cname + origin_name
  end

  def origin_zh_name
    "#{wine.origin_name.to_s} #{wine.name_zh.to_s}"
  end

  def other_cn_name
    wine.other_cn_name
  end

  # 获取产区
  def get_region_path_html( symbol = " > " )
    wine.get_region_path.reverse!.collect { |region| region.origin_name + '/' + region.name_zh }.join( symbol )
  end

  def is_nv?
    self.is_nv == 1
  end
  
  def show_year
    if is_nv?
      'NV'
    else
      year.strftime("%Y") unless year.blank?
    end
  end

  def self.approve_wine_detail(wine_id, register, audit_log_id)
    wine_detail = Wines::Detail.find_or_initialize_by_wine_id_and_year(wine_id, register.vintage)
    if wine_detail.new_record?
      wine_detail.update_attributes!(
        :drinkable_begin => register.drinkable_begin,
        :drinkable_end => register.drinkable_end,
        :alcoholicity => register.alcoholicity,
        :capacity => register.capacity,
        :wine_style_id => register.wine_style_id,
        :audit_id => audit_log_id,
        :user_id => register.user_id,
        :is_nv => register.is_nv,
        :description => register.description
      )
    end
    return wine_detail
  end

  def show_region_percentage
    show_percentage = ""
    variety_percentages.includes(:variety).each do |p|
      show_percentage << " #{p.name_zh}-#{p.origin_name}/#{p.percentage} "
    end
    return show_percentage
  end
  
  def show_capacity
    capacity.present? ? APP_DATA['wines']['capacity'].invert[capacity] : "其他"
  end
  
  # 谁拥有这些酒
  def owners(options = {})
     Users::WineCellarItem.all(:include => [:user],
                               :conditions => ["wine_detail_id = ?", id],
                               :order => "number DESC, created_at DESC", :limit => options[:limit])
  end

  # 所有评论， 不包含子评论
  def all_comments(options = { })
    @comments  =  ::Comment.all(:include => [:user],
                                # :joins => :votes,
                                :joins => "LEFT OUTER JOIN `votes` ON comments.id = votes.votable_id",
                                :select => "comments.*, count(votes.id) as votes_count",
                                :conditions => ["commentable_id=? AND parent_id IS NULL", id ], :group => "comments.id",
                                :order => "votes_count DESC, created_at DESC", :limit => options[:limit] )
  end

  # 所有评论的总数（评论数)
  def all_comments_count
    comments_count
  end

  #展示detail covers 如果没有则展示wine 的covers
  def show_covers
    if covers.approved.present?
      photo_covers = covers.approved
    elsif wine.covers.approved.present?
      photo_covers = wine.covers.approved
    end
    return photo_covers
  end

  def show_alcoholicity
    alcoholicity.blank? ? nil : "#{alcoholicity}%Vol"
  end

  def all_photo_ids
   all_photos.inject([]) {|memo, p| memo << p.id}
  end

  def all_photos
    Photo.approved.where(["(imageable_type=? AND imageable_id = ?) OR (imageable_type=? AND imageable_id =? )", "Wines::Detail", id, "Wine", wine_id])
  end

  def all_photo_counts
    photos_count.to_i + wine.photos_count.to_i
  end

  # 是否已经关注酒
  def is_followed_by? user
   follows.where("user_id = ? ", user.id).first
  end

  # 当前关注该支酒的用户列表
  def followers(options = { })
    User.joins(:follows).
      where("followable_type = ? AND followable_id = ?", self.class.name, id)
  end

  def get_cover_url(version)
    cover = photos.cover.approved.first
    if cover.nil?
      wine_cover = wine.photos.cover.approved.first
      if wine_cover.blank?
        return "/assets/waterfall/images/common/wine_#{version}.png" 
      else
        wine_cover.image_url(version)
      end
    end
  end
  # 类方法
  class << self
   def timeline_events
     TimelineEvent.wine_details
   end
  end
end
