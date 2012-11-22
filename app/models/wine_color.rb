class WineColor < ActiveRecord::Base
  attr_accessible :image, :key, :name_en, :name_zh, :parent_id
  def name
    "#{name_zh} #{name_en}"
  end
end
