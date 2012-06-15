# encoding: UTF-8
class Wines::Register < ActiveRecord::Base

  include Wines::WineSupport, Common

  belongs_to :user
  belongs_to :style, :foreign_key => 'wine_style_id'
  belongs_to :winery
  belongs_to :region_tree, :foreign_key => 'region_tree_id'
  has_many :special_comments, :as => :special_commentable
  has_many :photos, :as => :imageable, :class_name => "Photo"
  has_many :covers, :as => :imageable, :class_name => "Photo", :conditions => { :photo_type => APP_DATA["photo"]["photo_type"]["cover"] }
  has_one :label, :as => :imageable, :class_name => "Photo", :conditions => { :photo_type => APP_DATA["photo"]["photo_type"]["label"] }
  attr_accessor :crop_x, :crop_y, :crop_w, :crop_h, :variety_name_value, :variety_percentage_value, :owner_type, :business_id

  ## upload image with carrierwave
  mount_uploader :photo_name, WineRegisterUploader

  serialize :variety_name, Array
  serialize :variety_percentage, Array

  validates :name_en, :presence => true
  validates :vintage, :presence => true, :if => "is_nv.to_i != 1"
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

  def approve_wine
    audit_log = AuditLog.build_log(id, 4)
    self.update_attributes!(:audit_log_id => audit_log.id, :status => 1, :result => 1)
    wine = Wine.approve_wine(self)
    wine_detail = Wines::Detail.approve_wine_detail(wine.id, self, audit_log.id)
    Wines::VarietyPercentage.build_variety_percentage(variety_name, variety_percentage, wine_detail.id)
    Wines::SpecialComment.change_special_comment_to_wine(wine_detail, self)
    Photo.build_wine_photo(:wine_register_id => id, 
      :wine_detail => wine_detail,
      :width => width , 
      :height => height) unless photo_name.blank?
  end

  #更改csv文件结构后的程序
  def new_approve_wine
    audit_log = AuditLog.build_log(id, 4)
    self.update_attributes!(:audit_log_id => audit_log.id, :status => 1, :result => 1)
    wine = Wine.approve_wine(self)
    wine_detail = Wines::Detail.approve_wine_detail(wine.id, self, audit_log.id)
    Wines::VarietyPercentage.build_variety_percentage(variety_name, variety_percentage, wine_detail.id)
    return wine_detail.id
  end

  def show_status
    status.to_i == 0 ? "未发布" : (status.to_i == 1 ? "已发布" : "发布失败")
  end

  def show_result
    result.to_i == 0 ? "未发布" : (result.to_i == 1 ? "已发布" : "发布失败")
  end

  def ename
    "#{show_vintage} #{name_en.to_s}"
  end

  def show_vintage
    vintage.strftime("%Y") unless vintage.blank?
  end
end
