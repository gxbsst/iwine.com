class Wines::Style < ActiveRecord::Base
  include Wines::WineSupport
  has_many :registers
  def name
    "#{name_en}/#{name_zh}"
  end
end
