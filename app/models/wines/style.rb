class Wines::Style < ActiveRecord::Base
  include Wines::WineSupport
  has_many :registers
  has_many :details
  has_many :children, :class_name => :Style, :foreign_key => :parent_id
  belongs_to :parent, :class_name => :Style, :foreign_key => :parent_id
  
  def name
    "#{name_en}/#{name_zh}"
  end
end
