class Wines::Detail < ActiveRecord::Base
  include Wines::WineSupport
  
  belongs_to :wine
  has_many :comments, :foreign_key => 'wine_detail_id'
  #  has_many :good_comments, :foreign_key => 'wine_detail_id', :class_name => 'Wines::Comment', :order => 'good_hit DESC, id DESC', :limit => 5, :include => [:user_good_hit] 
  has_one :statistic, :foreign_key => 'wine_detail_id'
  has_one :cover, :class_name => 'Photo',  :foreign_key => 'business_id', :conditions => { :is_cover => true, :owner_type => OWNER_TYPE_WINE }
  has_many :photos, :class_name => 'Photo',  :foreign_key => 'business_id', :conditions => { :owner_type => OWNER_TYPE_WINE }
  has_many :prices, :class_name => "Price", :foreign_key => "wine_detail_id"
  has_many :variety_percentages, :class_name => 'VarietyPercentage', :foreign_key => 'wine_detail_id'
  belongs_to :audit_log, :class_name => "AuditLog", :foreign_key => "audit_id"
    
  def comment( user_id )
    Wines::Comment.find_by_user_id user_id
  end

  def best_comments( limit = 5 )
    Wines::Comment.find(:all, :include => [:user, :avatar, :user_good_hit], :limit => limit, :conditions => ["wine_detail_id = ?", id])
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
  
end
