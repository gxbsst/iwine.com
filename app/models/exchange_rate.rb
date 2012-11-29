class ExchangeRate < ActiveRecord::Base
  attr_accessible :name_en, :name_zh, :rate
  
  def name
    "#{name_en}/#{name_zh}"
  end
end
