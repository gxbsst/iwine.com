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
  validate :vintage_and_is_nv_presence

  def vintage_and_is_nv_presence
    if vintage && is_nv
      errors.add(:vintage,  "年份 和 NV 只能选择一个。")
    elsif !vintage && !is_nv
      errors.add(:vintage, "年份不能为空。")
    end  
  end

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
    split_name_zh
    find_and_init_winery_cn_names
    audit_log = AuditLog.build_log(id, 4)
    self.update_attributes!(:audit_log_id => audit_log.id, :status => 1, :result => 1)
    wine = Wine.approve_wine(self)
    wine_detail = Wines::Detail.approve_wine_detail(wine.id, self, audit_log.id)
    Wines::VarietyPercentage.build_variety_percentage(variety_name, variety_percentage, wine_detail)
    Wines::SpecialComment.change_special_comment_to_wine(wine_detail, self)
    Photo.build_wine_photo(:wine_register_id => id, 
      :wine_detail => wine_detail,
      :width => width , 
      :height => height) unless photo_name.blank?
  end

  #更改csv文件结构后的程序
  def new_approve_wine(logger = nil)
    split_name_zh
    find_and_init_winery_cn_names
    #打印variety_percent 日志
    audit_log = AuditLog.build_log(id, 4)
    self.update_attributes!(:audit_log_id => audit_log.id, :status => 1, :result => 1)
    wine = Wine.approve_wine(self)
    wine_detail = Wines::Detail.approve_wine_detail(wine.id, self, audit_log.id)
    Wines::VarietyPercentage.build_variety_percentage(variety_name, variety_percentage, wine_detail, logger)
    Wines::SpecialComment.change_special_comment_to_wine(wine_detail, self)
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

  def oname
    "#{show_vintage} #{origin_name.to_s}"
  end

  def show_vintage
    vintage.strftime("%Y") unless vintage.blank?
  end
  #仅在发布时使用
  #将用户输入的多个酒的中文名转化为一个数组
  def split_name_zh
    if name_zh.present? && user_id != -1
      name_arr = change_name_zh_to_array(name_zh)
      self.name_zh = name_arr.delete_at 0 
      self.other_cn_name = name_arr.join('/')
    end
  end
  
  #处理用户上传新酒款的酒庄中文名
  def find_and_init_winery_cn_names
    if user_id != -1 
      name_zh_arr = change_name_zh_to_array(winery_name_zh)
      if winery_id.blank?
        winery = Winery.find_winery(winery_name_en, winery_origin_name, name_zh_arr)
        update_attribute(:winery_id, winery.id) if winery
      else
        winery = Winery.find(winery_id)
      end
      if winery
        name_zh_arr.each do |name_zh|
          winery.cn_names.where(:name_zh => name_zh).
            first_or_create(:user_id => user_id,
                           :name_zh => name_zh)
        end
      end
    end
  end

  def change_name_zh_to_array(name)
    name.delete(' ').gsub(";", "；").split("；")
  end
end
