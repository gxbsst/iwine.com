class InfoItem < ActiveRecord::Base
  set_table_name "info_items"
  include Wines::WineSupport
  belongs_to :winery
end
