# Attributes:
# * id [integer, primary, not null, limit=4] - primary key
# * created_at [datetime, not null] - creation time
# * parent_id [integer, default=0, not null, limit=2] - belongs to Region
# * region_name [string, default=, not null] - TODO: document me
# * region_type [integer, limit=4] - TODO: document me
# * updated_at [datetime, not null] - last update time
class Region < ActiveRecord::Base
  
  has_many :children, :class_name => self, :foreign_key => "parent_id" #, :select => [:name_en, :name_zh]
  belongs_to :parent, :class_name => self, :foreign_key => "parent_id" #, :select => [:name_en, :name_zh]
  
  scope :locals, lambda {|parent_id| where(["parent_id = ?", parent_id])}
  scope :provinces, lambda {|parent_id| where(["parent_id = ? AND region_type = 1", parent_id]) }
  scope :cities, lambda {|parent_id| where(["parent_id = ? AND region_type = 2", parent_id]) }
  scope :districts, lambda {|parent_id| where(["parent_id = ? AND region_type = 3", parent_id]) }
end
