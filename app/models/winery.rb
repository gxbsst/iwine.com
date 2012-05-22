class Winery < ActiveRecord::Base
  set_table_name "wineries"
  include Wines::WineSupport

  has_many :registers
  has_many :info_items, :class_name => "InfoItem"
  has_many :photos, :class_name => 'Photo',  :foreign_key => 'business_id', :order => 'created_at DESC', :conditions => { :owner_type => OWNER_TYPE_WINERY }
  has_many :wines
  has_many :comments, :as => :commentable
  mount_uploader :logo, WineryUploader

  accepts_nested_attributes_for :photos
  accepts_nested_attributes_for :info_items, :reject_if => lambda {|t| t[:title].blank? }, :allow_destroy => true
  serialize :config, Hash
  serialize :counts, Hash
  def name
    name_en + '/' + name_zh    
  end

  def save_region_tree(region)
    region_tree_id = region.values.delete_if{|a| a == ''}.pop
    self.region_tree_id = region_tree_id unless region_tree_id.blank?
  end
end
