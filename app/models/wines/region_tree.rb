class Wines::RegionTree < ActiveRecord::Base
  include Wines::WineSupport
  has_many :children, :class_name => "RegionTree", :foreign_key => "parent_id" #, :select => [:name_en, :name_zh]
  belongs_to :parent, :class_name => "RegionTree", :foreign_key => "parent_id"
  
  scope :region, lambda {|parent_id| where(["parent_id = ?", parent_id])}
  scope :select_region, lambda {where(["parent_id is null"])} #上传酒款选择区域

  #清晰数据时查询region_tree的id
  def self.get_region_tree_id(name)
    region_tree = self.where("name_en = ?", name).order("level desc")
    region_tree.blank? || region_tree.size > 1 ? nil : region_tree.first.id
  end
end
