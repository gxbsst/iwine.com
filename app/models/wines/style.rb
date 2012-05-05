class Wines::Style < ActiveRecord::Base
  include Wines::WineSupport
  has_many :registers
  has_many :details
  def name
    "#{name_en}/#{name_zh}"
  end
end
