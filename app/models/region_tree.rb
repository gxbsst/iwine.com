class RegionTree < ActiveRecord::Base
  self.table_name = 'wine_region_trees'
  
  #has_many :children, :class_name => "RegionTree", :foreign_key => "parent_id" #, :select => [:name_en, :name_zh]
  #belongs_to :parent, :class_name => "RegionTree", :foreign_key => "parent_id"
end
