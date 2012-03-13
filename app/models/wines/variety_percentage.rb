class Wines::VarietyPercentage < ActiveRecord::Base
  include Wines::WineSupport

  belongs_to :detail, :foreign_key =>  'wine_detail_id'
  belongs_to :variety
end
