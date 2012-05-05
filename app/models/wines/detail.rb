#encoding: UTF-8
class Wines::Detail < ActiveRecord::Base

  paginates_per 10

  include Wines::WineSupport
  acts_as_commentable

  belongs_to :wine
  # has_many :comments, :foreign_key => 'wine_detail_id'
  #  has_many :good_comments, :foreign_key => 'wine_detail_id', :class_name => 'Wines::Comment', :order => 'good_hit DESC, id DESC', :limit => 5, :include => [:user_good_hit]
  has_one :statistic, :foreign_key => 'wine_detail_id'
  has_one :cover, :class_name => 'Photo',  :foreign_key => 'business_id', :conditions => { :is_cover => true, :owner_type => OWNER_TYPE_WINE }
  has_one :label
  has_many :photos, :class_name => 'Photo',  :foreign_key => 'business_id', :limit => 5, :order => 'created_at DESC', :conditions => { :owner_type => OWNER_TYPE_WINE }
  has_many :prices, :class_name => "Price", :foreign_key => "wine_detail_id"
  has_many :variety_percentages, :class_name => 'VarietyPercentage', :foreign_key => 'wine_detail_id', :dependent => :destroy
  belongs_to :audit_log, :class_name => "AuditLog", :foreign_key => "audit_id"
  belongs_to :style, :foreign_key => "wine_style_id"
  has_many :special_comments, :as => :special_commentable
  accepts_nested_attributes_for :photos, :reject_if => proc { |attributes| attributes['image'].blank? }
  accepts_nested_attributes_for :label, :reject_if => proc { |attributes| attributes['filename'].blank? }
  def comment( user_id )
    Wines::Comment.find_by_user_id user_id
  end

  def best_comments( limit = 5 )
    Wines::Comment.find(:all, :include => [:user, :avatar, :user_good_hit], :limit => limit, :conditions => ["wine_detail_id = ?", id])
  end

  def cname
    year.to_s + wine.name_zh.to_s
  end

  def ename
    year.to_s + wine.origin_name.to_s
  end

  def name
    cname + ename
  end

  def other_cn_name
    wine.other_cn_name
  end

  def get_region_path_html( symbol = " > " )
    get_region_path.reverse!.collect { |region| region.name_en + '/' + region.name_zh }.join( symbol )
  end

  def drinkable
    drinkable_begin.to_s + ' - ' + drinkable_end.to_s
  end

  def show_year
    year.blank? ? '年代未知' : year.strftime("%Y")
  end

  def other_cn_name
    wine.other_cn_name
  end
  
  def get_region_path_html( symbol = " > " )
    get_region_path.reverse!.collect { |region| region.name_en + '/' + region.name_zh }.join( symbol )
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
        :audit_id => register.audit_log_id
      )
    end
    return wine_detail
  end

  def show_region_percentage
    show_percentage = ""
    variety_percentages.each do |p|
      show_percentage << " #{p.variety.name_zh}-#{p.variety.name_en}/#{p.percentage} "
    end
    return show_percentage
  end

end
