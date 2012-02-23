class WINES::Register < ActiveRecord::Base

  belongs_to :user
  belongs_to :style
  belongs_to :winery
  belongs_to :region_tree, :foreign_key => 'region_tree_id'

end
