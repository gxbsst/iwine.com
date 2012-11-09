class ExchangeRate < ActiveRecord::Base
  attr_accessible :name_en, :name_zh, :rate
end
