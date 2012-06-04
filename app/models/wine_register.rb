# Attributes:
# * id [integer, primary, not null, limit=4] - primary key
# * alcoholicity [string] - TODO: document me
# * audit_log_id [integer, limit=4] - TODO: document me
# * capacity [string] - TODO: document me
# * created_at [datetime, not null] - creation time
# * description [text] - TODO: document me
# * drinkable_begin [datetime] - TODO: document me
# * drinkable_end [datetime] - TODO: document me
# * height [integer, limit=4] - TODO: document me
# * is_nv [integer, default=0, limit=1] - TODO: document me
# * name_en [string] - TODO: document me
# * name_zh [string] - TODO: document me
# * official_site [string] - TODO: document me
# * origin_name [string] - TODO: document me
# * other_cn_name [string] - TODO: document me
# * photo_name [string] - TODO: document me
# * photo_origin_name [string] - TODO: document me
# * region_tree_id [integer, limit=4] - TODO: document me
# * result [integer, limit=4] - TODO: document me
# * status [integer, default=0, limit=1] - TODO: document me
# * updated_at [datetime, not null] - last update time
# * user_id [integer, limit=4] - TODO: document me
# * variety_name [string] - TODO: document me
# * variety_percentage [string] - TODO: document me
# * vintage [datetime] - TODO: document me
# * width [integer, limit=4] - TODO: document me
# * wine_style_id [integer, limit=4] - TODO: document me
# * winery_id [integer, limit=4] - TODO: document me
class WineRegister < ActiveRecord::Base
  # upload photo
  mount_uploader :photo_name, WineRegisterUploader
  serialize [:variety_percentage, :variety_name]
end
