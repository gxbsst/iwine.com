class Region < ActiveRecord::Base
  
  has_many :children, :class_name => self, :foreign_key => "parent_id" #, :select => [:name_en, :name_zh]
  belongs_to :parent, :class_name => self, :foreign_key => "parent_id" #, :select => [:name_en, :name_zh]
  
  scope :locals, lambda {|parent_id| where(["parent_id = ?", parent_id])}
  scope :provinces, lambda {|parent_id| where(["parent_id = ? AND region_type = 1", parent_id]) }
  scope :cities, lambda {|parent_id| where(["parent_id = ? AND region_type = 2", parent_id]) }
  scope :districts, lambda {|parent_id| where(["parent_id = ? AND region_type = 3", parent_id]) }
end
