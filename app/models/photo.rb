#class Photo < ActiveRecord::Base
#  attr_accessor :crop_x, :crop_y, :crop_w, :crop_h
#  belongs_to :user
#
#  mount_uploader :image, ImageUploader
#
#  ## FIXED
#  ## 修改image_uploader.rb 中 is_user? 的model的数据为空的bugs
#
##  after_update :recreate_delayed_versions!
##
##
##  def recreate_delayed_versions!
##    image.should_process = true
##    image.recreate_versions! if crop_x.present?
###    self.image.recreate_versions! if self.image.present?
##  end
#
#
#end

class Photo < ActiveRecord::Base

  mount_uploader :image, ImageUploader
  attr_accessor :crop_x, :crop_y, :crop_w, :crop_h
  #after_update :crop_avatar
  after_save :recreate_delayed_versions!

  #def crop_avatar
  #  image.recreate_versions! if crop_x.present?
  #end

  def recreate_delayed_versions!
      image.should_process = true
      image.recreate_versions!
  end

end
