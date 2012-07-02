class Wines::RegionTree < ActiveRecord::Base
  include Wines::WineSupport
  has_many :children, :class_name => "RegionTree", :foreign_key => "parent_id" #, :select => [:name_en, :name_zh]
  belongs_to :parent, :class_name => "RegionTree", :foreign_key => "parent_id"
  
  scope :region, lambda {|parent_id| where(["parent_id = ?", parent_id])}
  scope :select_region, lambda {where(["parent_id is null"])} #上传酒款选择区域

  #清晰数据时查询region_tree的id
  #规则1：最低级别如果出现重复的名字设置为空
  #规则2：同一线路上例如“库约  Cuyo  门多萨 Mendoza    Mendoza"，则将使用最后一个级别 
  def self.get_region_tree_id(name)
    region_tree = self.where("name_en = ?", name).order("level desc")
    region_tree_id_arr = region_tree.select{|a| a.children.blank?} #规则2
    region_tree_id_arr.blank? || region_tree_id_arr.size > 1 ? nil : region_tree_id_arr.first.id
  end
end
