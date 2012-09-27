#encoding: utf-8
class Wine < ActiveRecord::Base
  attr_accessor :all_years, :image_url, :slug
  include Common
  has_many   :details, :class_name => '::Wines::Detail', :order => 'year DESC'
  has_many   :special_comments, :as => :special_commentable
  belongs_to :winery
  belongs_to :style, :class_name => "::Wines::Style", :foreign_key => "wine_style_id"
  belongs_to :region_tree, :class_name => "::Wines::RegionTree", :foreign_key => "region_tree_id"
  has_many   :photos, :as => :imageable
  has_many   :covers, :as => :imageable, 
    :class_name => "Photo", 
    :conditions => {:photo_type => APP_DATA["photo"]["photo_type"]["cover"]}
  has_one :label, :as => :imageable, 
    :class_name => "Photo", 
    :conditions => {:photo_type => APP_DATA["photo"]["photo_type"]["label"]}

  counts :photos_count   => {:with => "AuditLog",
    :receiver => lambda {|audit_log| audit_log.logable.imageable }, 
    :increment => {
    :on => :create,
    :if => lambda {|audit_log| audit_log.photos_counter_should_increment? &&
      audit_log.logable.imageable_type == "Wine" }
  },
    :decrement => {
    :on => :save, 
    :if => lambda {|audit_log| audit_log.photos_counter_should_decrement? && 
      audit_log.logable.imageable_type == "Wine" }
  }                              
  }

  def self.approve_wine(register)
    wine = Wine.find_or_initialize_by_name_en(register.name_en)
    if wine.new_record?
      wine.update_attributes!(
        :origin_name => register.origin_name,
        :name_zh => register.name_zh,
        :other_cn_name => register.other_cn_name,
        :official_site => register.official_site,
        :wine_style_id => register.wine_style_id,
        :region_tree_id => register.region_tree_id,
        :winery_id => register.winery_id
      )
    end
    return wine
  end

  #发评论时分享用
  def share_name
    "【#{origin_name}】"
  end

  def get_latest_detail
    details.order("year desc").first
  end

  def years 
    details.collect {|wine| [wine.year.year, wine.slug]}
  end

  
  def copy_detail(detail, is_nv, year)
    #查找detail
    if is_nv
      wine_detail = details.where("is_nv = ?", 1).first
    else
      wine_detail = details.where("year like ?", "#{year}%").first
    end
    if wine_detail
      return wine_detail
    else
      #创建detail
      wine_detail = Wines::Detail.new(:wine_id => id)
      if is_nv
        wine_detail.is_nv = true 
      else
        wine_detail.year = Time.mktime(year) 
      end
      wine_detail.save
      return wine_detail
    end
  end
end
