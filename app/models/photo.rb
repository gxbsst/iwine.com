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
require 'fileutils'
class Photo < ActiveRecord::Base

  belongs_to :album
  belongs_to :user
  belongs_to :wine_detail, :class_name => 'Wines::Detail', :foreign_key => 'business_id'
  belongs_to :winery, :foreign_key => "business_id"

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

  def self.build_wine_photo(wine_detail_id, wine_register_id)
    check_wine_dir(wine_detail_id)
    photo_path = copy_photo(wine_register_id, wine_detail_id)
    Photo.create(
        :owner_type => 2,
        :business_id => wine_detail_id,
        :category => 1,
        :album_id => -1, # no user id
        :is_cover => 1,
        :image => open(photo_path))
  end

  def self.check_wine_dir(wine_detail_id)
    Dir.mkdir "#{Rails.root}/public/uploads/photo" unless Dir.exist? "#{Rails.root}/public/uploads/photo"
    Dir.mkdir "#{Rails.root}/public/uploads/photo/wine" unless Dir.exist? "#{Rails.root}/public/uploads/photo/wine"
    Dir.mkdir("#{Rails.root}/public/uploads/photo/wine/#{wine_detail_id}") unless Dir.exist? "#{Rails.root}/public/uploads/photo/wine/#{wine_detail_id}"

  end

  def self.copy_photo(wine_register_id, wine_detail_id)
    FileUtils.cp_r Dir.glob("#{Rails.root}/public/uploads/wines/register/#{wine_register_id}/*"), "#{Rails.root}/public/uploads/photo/wine/#{wine_detail_id}"
    Rails.root.join 'public', 'uploads', 'photo', 'wine', wine_detail_id.to_s, Dir.entries(Rails.root.join('public', 'uploads','photo', 'wine', wine_detail_id.to_s)).select{|x| x != '.' && x != '..' && x != '.DS_Store'}.first
  end
end
