# -*- coding: utf-8 -*-
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

  belongs_to :album
  acts_as_commentable

  delegate :user_id, :to => :album

  paginates_per 12

  mount_uploader :image, ImageUploader
  attr_accessor :crop_x, :crop_y, :crop_w, :crop_h
  #after_update :crop_avatar
  after_save :recreate_delayed_versions!

  after_destroy :update_album_delete

  #def crop_avatar
  #  image.recreate_versions! if crop_x.present?
  #end

  def recreate_delayed_versions!
      image.should_process = true
      image.recreate_versions!
  end

  def update_album_delete
    album.photos_num -= 1;
    album.save
  end

end
