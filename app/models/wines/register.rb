class Wines::Register < ActiveRecord::Base

  include Wines::WineSupport

  belongs_to :user
  belongs_to :style, :foreign_key => 'wine_style_id'
  belongs_to :winery
  belongs_to :region_tree, :foreign_key => 'region_tree_id'

end
