class WineTrait < ActiveRecord::Base
  attr_accessible :key, :name_en, :name_zh, :parent_id

  def name
    "#{name_zh} #{name_en}"
  end
end
