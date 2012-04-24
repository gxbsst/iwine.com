class Wines::Variety < ActiveRecord::Base
  include Wines::WineSupport
  has_many :variety_percentages
end
