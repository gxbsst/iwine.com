# encoding UTF-8
class Wines::Register < ActiveRecord::Base

  include Wines::WineSupport

  belongs_to :user
  belongs_to :style, :foreign_key => 'wine_style_id'
  belongs_to :winery
  belongs_to :region_tree, :foreign_key => 'region_tree_id'
  has_many :special_comments, :as => :special_commentable
  attr_accessor :crop_x, :crop_y, :crop_w, :crop_h, :variety_name_value, :variety_percentage_value, :owner_type, :business_id

  ## upload image with carrierwave
  mount_uploader :photo_name, WineRegisterUploader

  serialize :variety_name, Array
  serialize :variety_percentage, Array

  validates :name_en, :region_tree_id, :presence => true
  def self.has_translation(*attributes)
    attributes.each do |attribute|
      define_method "#{attribute}" do
        self.send "#{attribute}_#{I18n.locale}"
      end
    end
  end

  def show_vintage
    vintage.blank? ? "-" : vintage.strftime("%Y")
  end

end
