class Winery < ActiveRecord::Base
  def name
    name_en + '/' + name_zh    
  end
end
