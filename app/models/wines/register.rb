class Wines::Register < ActiveRecord::Base

  include Wines::WineSupport

  attr_accessible :variety_name_value, :variety_percentage_value

  belongs_to :user
  belongs_to :style, :foreign_key => 'wine_style_id'
  belongs_to :winery
  belongs_to :region_tree, :foreign_key => 'region_tree_id'

  ## upload image with carrierwave
  mount_uploader :photo_name, ImageUploader
  attr_accessor :crop_x, :crop_y, :crop_w, :crop_h
  #after_update :crop_avatar
  after_update :recreate_delayed_versions!

  #def crop_avatar
  #  image.recreate_versions! if crop_x.present?
  #end

  def recreate_delayed_versions!
    image.should_process = true
    image.recreate_versions!
  end

  def self.has_translation(*attributes)
    attributes.each do |attribute|
      define_method "#{attribute}" do
        self.send "#{attribute}_#{I18n.locale}"
      end
    end
  end

end
