# encoding: utf-8
class Users::Profile < ActiveRecord::Base
  include Users::UserSupport
  belongs_to :user
  # delegate :username, :to => :user
  delegate :email, :to => :user
  # delegate :city, :to => :user
  # attr_accessor :username, :city
  # validates :username, :city,  :presence => true, :on => :update
  

  store_configurable

  before_save :init_configs

  def get_living_city_path
    unless living_city.blank?
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
      config.share.follow_wine_or_winery = public

      # 通知设置
      config.notice.email   = email_config
      config.notice.message = public
      config.notice.comment = public
    end
  end

end

