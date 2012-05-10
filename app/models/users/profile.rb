# encoding: utf-8
class Users::Profile < ActiveRecord::Base

  include Users::UserSupport

  belongs_to :user

  attr_accessor :username

  # validates_numericality_of :qq,  :message => "数据格式不对", :allow_nil => true
  # validates :contact_email, :msn, :email_format => true, :allow_blank => true, :on => :update

  # validates :qq, :presence => false, :allow_blank => true, :numericality => true, :on => :update

  validates :username, :presence => true, :on => :update

  delegate :username, :to => :user
  delegate :email, :to => :user
  # validates_numericality_of :qq, :message => "请输入正确的格式"
  # attr_protected :_config
  #attr_accessible :province, :city, :district
  store_configurable

  before_save :init_configs

  def get_living_city_path
    if living_city.blank?
      region = Region.find(living_city)
      parent = region.parent
      path = []
      path << region
      until parent == nil
        path << parent
        parent = parent.parent
      end
      path.reverse!
    end
  end

  def get_living_city
    city_path = get_living_city_path
    if city_path.nil?
      "未知"
    else
      city_path.map(:region_name)
    end
  end

  # ## 定义config的默认值
  # def method_missing(method_name)
  #   if method_name.to_s =~ /^(config_share_|config_notice_)(\w+)$/
  #     string_1 = $1
  #     string_2 = $2
  #     string = (string_1.gsub("_", ".") << string_2)
  #     config_value  = eval(string)
  #     if config_value.blank?
  #       binding.pry
  #       # 如果是新记录默认为true
  #       _config.blank? ? true : false
  #     else
  #       # 默认值
  #       config_value
  #     end
  #   else
  #     super
  #   end
  # end

  # TODO before save if is new record init config values

  ####################
  # Private Function #
  ####################

  private

  def init_configs
    if new_record?
      # 初始化值
      public = APP_DATA["user_profile"]["configs"]["defaults"]["normal"].to_s
      email_config = APP_DATA["user_profile"]["configs"]["defaults"]["email"].to_s

      # 默认分享
      config.share.wine_cellar         = public
      config.share.wine_detail_comment = public
      config.share.wine_simple_comment = public

      # 通知设置
      config.notice.email   = email_config
      config.notice.message = public
      config.notice.comment = public
    end
  end

end

