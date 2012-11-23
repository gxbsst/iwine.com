class WineTrait < ActiveRecord::Base
  attr_accessor :select

  attr_accessible :key, :name_en, :name_zh, :parent_id, :select

  def name
    "#{name_zh} #{name_en}"
  end

  def select
    @select
  end

  def mark_select
    @select = 'rg'
  end

end
