# Attributes:
# * id [integer, primary, not null, limit=4] - primary key
# * created_at [datetime, not null] - creation time
# * description [text] - TODO: document me
# * title [string]
# * updated_at [datetime, not null] - last update time
# * winery_id [integer, limit=4] - belongs to Winery
class InfoItem < ActiveRecord::Base
  set_table_name "info_items"
  include Wines::WineSupport
  belongs_to :winery
end
