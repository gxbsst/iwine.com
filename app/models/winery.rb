# Attributes:
# * id [integer, primary, not null, limit=4] - primary key
# * address [string] - TODO: document me
# * cellphone [string] - TODO: document me
# * comments_count [integer, default=0, limit=4] - TODO: document me
# * config [string] - TODO: document me
# * counts [string] - TODO: document me
# * created_at [datetime, not null] - creation time
# * email [string]
# * fax [string] - TODO: document me
# * followers_count [integer, default=0, limit=4] - TODO: document me
# * logo [string] - TODO: document me
# * name_en [string] - TODO: document me
# * name_zh [string] - TODO: document me
# * official_site [string] - TODO: document me
# * origin_name [string] - TODO: document me
# * owner [string] - TODO: document me
# * photos_count [integer, default=0, limit=4] - TODO: document me
# * region_tree_id [integer, limit=4] - TODO: document me
# * updated_at [datetime, not null] - last update time
# * wines_count [integer, default=0, limit=4] - TODO: document me
class Winery < ActiveRecord::Base
  set_table_name "wineries"
  include Wines::WineSupport, Common
  include Common
  # 统计评论数量
  counts :comments_count => {:with => "Comment", 
                             :receiver => lambda {|comment| comment.commentable },
                             :increment => {:on => :create, :if => lambda {|comment| comment.counter_should_increment_for("Winery")}},
                             :decrement => {:on => :save, :if   => lambda {|comment| comment.counter_should_decrement_for("Winery")}}                              
                             },
         :followers_count => {
                             :with => "Comment",
                             :receiver => lambda {|comment| comment.commentable },
                             :increment => {:on => :create, :if => lambda {|comment| comment.followers_counter_should_increment_for("Winery")}},
                             :decrement => {:on => :save,   :if => lambda {|comment| comment.followers_counter_should_decrement_for("Winery")}}                              
                            },
           :photos_count   => {:with => "AuditLog",
                                        :receiver => lambda {|audit_log| audit_log.logable.imageable }, 
                                        :increment => {:on => :create, :if => lambda {|audit_log| audit_log.photos_counter_should_increment? && audit_log.logable.imageable_type == "Winery"}},
                                        :decrement => {:on => :save,   :if => lambda {|audit_log| audit_log.photos_counter_should_decrement? && audit_log.logable.imageable_type == "Winery"}}                              
                             }

  has_many :registers
  has_many :info_items, :class_name => "InfoItem"
  has_many :photos, :as => :imageable
  has_many :covers, :as => :imageable, :class_name => "Photo", :conditions => {:photo_type => APP_DATA["photo"]["photo_type"]["cover"]}
  has_one :label, :as => :imageable, :class_name => "Photo", :conditions => {:photo_type => APP_DATA["photo"]["photo_type"]["label"]}
  has_many :wines
  has_many :comments, :class_name => "WineryComment", :as => :commentable
  scope :hot_wineries, lambda { |limit| joins(:comments).
                                        includes([:covers]).
                                        where("do = ?", "follow").
                                        select("wineries.*, count(*) as c").
                                        group("commentable_id").
                                        order("c DESC").
                                        limit(limit)
                           }
  mount_uploader :logo, WineryUploader

  accepts_nested_attributes_for :photos, :allow_destroy => true
  accepts_nested_attributes_for :info_items, :reject_if => lambda {|t| t[:title].blank? }, :allow_destroy => true
  serialize :config, Hash

  def name
    origin_name + '/' + name_zh    
  end

  def save_region_tree(region)
    region_tree_id = region.values.delete_if{|a| a == ''}.pop
    self.region_tree_id = region_tree_id unless region_tree_id.blank?
  end

  def all_comments_count
    comments_count + followers_count
  end
  # 类方法
  class << self
    def timeline_events
      TimelineEvent.wineries
    end
  end

 end
