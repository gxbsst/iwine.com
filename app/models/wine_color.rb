class WineColor < ActiveRecord::Base

  attr_accessor :select

  attr_accessible :image, :key, :name_en, :name_zh, :parent_id, :select

  def name
    "#{name_zh} #{name_en}"
  end


  #def select
  #  @select
  #end

  def mark_select
    self.select = 'rg'
  end


end
