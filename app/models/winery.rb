class Winery < ActiveRecord::Base
  set_table_name "wineries"
  include Wines::WineSupport
  has_many :registers
  has_many :info_items, :class_name => "InfoItem"
  has_many :photos, :as => :imageable
  has_many :covers, :as => :imageable, :class_name => "Photo", :conditions => {:is_cover => true}, :limit => 1
  has_many :wines
  has_many :comments, :class_name => "WineryComment", :as => :commentable

  mount_uploader :logo, WineryUploader

  accepts_nested_attributes_for :photos
  accepts_nested_attributes_for :info_items, :reject_if => lambda {|t| t[:title].blank? }, :allow_destroy => true
  serialize :config, Hash

  def name
    name_en + '/' + name_zh    
  end

  def save_region_tree(region)
    region_tree_id = region.values.delete_if{|a| a == ''}.pop
    self.region_tree_id = region_tree_id unless region_tree_id.blank?
  end

end
