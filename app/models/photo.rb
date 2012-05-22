# -*- coding: utf-8 -*-
require 'fileutils'
class Photo < ActiveRecord::Base
  # fires :new_photo, :on                 => :create,
  #                     :actor              => :user,
  #                     :secondary_actor => :imageable,
  #                     :if => lambda { |imageable| imageable.imageable_type == "Wines::Detail" }
  
  belongs_to :imageable, :polymorphic => true
  belongs_to :user
  has_many :comments, :as => :commentable
  has_many :comments, :class_name => "PhotoComment", :as => :commentable, :include => [:user]

  acts_as_commentable

  acts_as_votable

  delegate :user_id, :to => :album

  paginates_per 12

  mount_uploader :image, ImageUploader
  attr_accessor :crop_x, :crop_y, :crop_w, :crop_h
  #after_update :crop_avatar
  after_save :recreate_delayed_versions!
  after_destroy :update_album_delete

  serialize :counts, Hash

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

  def self.build_wine_photo(opts = {})
    check_wine_dir(opts[:wine_detail].id)
    photo_path = copy_photo(opts[:wine_register_id], opts[:wine_detail].id)
    opts[:wine_detail].photos.create(
        :category => 1,
        :album_id => -1, # no user id
        :is_cover => 1,
        :height => opts[:height],
        :width => opts[:width],
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
