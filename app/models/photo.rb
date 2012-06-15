# -*- coding: utf-8 -*-
require 'fileutils'
class Photo < ActiveRecord::Base
  # fires :new_photo, :on                 => :create,
  #                     :actor              => :user,
  #                     :secondary_actor => :imageable,
  #                     :if => lambda { |imageable| imageable.imageable_type == "Wines::Detail" }
  belongs_to :album, :touch => true
  belongs_to :imageable, :polymorphic => true
  belongs_to :user
  has_many :comments, :class_name => "PhotoComment", :as => :commentable, :include => [:user]
  has_many :audit_logs, :class_name => "AuditLog", :foreign_key => "audit_id"
  acts_as_commentable

  acts_as_votable

  paginates_per 12

  mount_uploader :image, ImageUploader
  attr_accessor :crop_x, :crop_y, :crop_w, :crop_h, :is_audit_status_changed #在update_photo的地方将此字段设置为true
  #after_update :crop_avatar
  after_save :recreate_delayed_versions!
  before_update :set_audit_status_changed?
  serialize :counts, Hash

  scope :covers, where(:photo_type => APP_DATA["photo"]["photo_type"]["cover"])
  scope :labels, where(:photo_type => APP_DATA["photo"]["photo_type"]["label"])
  scope :label, labels.limit(1) #取出一个 label
  scope :cover, covers.limit(1) #取出一个 cover
  #def crop_avatar
  #  image.recreate_versions! if crop_x.present?
  #end

  def recreate_delayed_versions!
      image.should_process = true
      image.recreate_versions!
  end

  def self.build_wine_photo(opts = {})
    check_wine_dir(opts[:wine_detail].id)
    photo_path = copy_photo(opts[:wine_register_id], opts[:wine_detail].id)
    opts[:wine_detail].photos.create(
        :category => 1,
        :album_id => -1, # no user id
        :photo_type => APP_DATA["photo"]["photo_type"]["cover"],
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

  #one convenient method to pass jq_upload the necessary information
  def to_jq_upload
    {   
      "name" => read_attribute(:image),
      "size" => image.size,
      "url" => image.url,
      "id" => id,
      "album_id" => album_id,
      "thumbnail_url" => image.thumb_x.url,
      "delete_url" => "...",
      "delete_type" => "DELETE"
    }
  end

  #audit_status 改变就在audit_log 增加一条记录
  def set_audit_status_changed?
    if audit_status_changed?
      self.is_audit_status_changed = true
    end
  end
end
