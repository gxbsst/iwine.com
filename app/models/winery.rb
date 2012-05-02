class Winery < ActiveRecord::Base
  has_many :registers
  def name
    name_en + '/' + name_zh    
  end
end
