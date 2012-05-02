class Wines::RegionTree < ActiveRecord::Base
  include Wines::WineSupport
  has_many :children, :class_name => "RegionTree", :foreign_key => "parent_id" #, :select => [:name_en, :name_zh]
  belongs_to :parent, :class_name => "RegionTree", :foreign_key => "parent_id"
  
  scope :region, lambda {|parent_id| where(["parent_id = ?", parent_id])}
  
end
