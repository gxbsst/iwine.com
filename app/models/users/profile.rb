class Users::Profile < ActiveRecord::Base
  include Users::UserSupport
  belongs_to :user
<<<<<<< HEAD
  
  attr_accessor :username
  
  # validates_numericality_of :qq,  :message => "数据格式不对", :allow_nil => true
  validates :contact_email, :msn, :email_format => true, :allow_blank => true
  
  validates :qq, :presence => false, :allow_blank => true, :numericality => true
  
  validates :username, :presence => true
  
  delegate :username, :to => :user
 # validates_numericality_of :qq, :message => "请输入正确的格式"  
  # attr_protected :_config
  #attr_accessible :province, :city, :district
  store_configurable
  
  def get_living_city_path
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
=======
end
>>>>>>> develop
