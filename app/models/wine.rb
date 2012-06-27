class Wine < ActiveRecord::Base
  include Common
  has_many   :details, :class_name => '::Wines::Detail'
  has_many   :special_comments, :as => :special_commentable
  belongs_to :winery
  belongs_to :style, :class_name => "::Wines::Style", :foreign_key => "wine_style_id"
  belongs_to :region_tree, :class_name => "::Wines::RegionTree", :foreign_key => "region_tree_id"
  has_many   :photos, :as => :imageable
  has_many   :covers, :as => :imageable, :class_name => "Photo", :conditions => {:photo_type => APP_DATA["photo"]["photo_type"]["cover"]}
  has_one    :label, :as => :imageable, :class_name => "Photo", :conditions => {:photo_type => APP_DATA["photo"]["photo_type"]["label"]}

  counts  :photos_count   => {:with => "AuditLog",
                              :receiver => lambda {|audit_log| audit_log.logable.imageable }, 
                              :increment => {:on => :create, :if => lambda {|audit_log| audit_log.photos_counter_should_increment? && audit_log.logable.imageable_type == "Wine" }},
                              :decrement => {:on => :save,   :if => lambda {|audit_log| audit_log.photos_counter_should_decrement? && audit_log.logable.imageable_type == "Wine" }}                              
                             }

  # Setup accessible (or protected) attributes for your model
  #attr_accessible :email, :password, :password_confirmation, :remember_me, :username

  #has_one :user_profile
  #has_many :albums
  #has_many :wine_registers
  #has_many :wine_comments
  #has_many :photo_comments

  # accepts_nested_attributes_for :user_profile
	# alias :user_profiles_attribute :user_profile

	#验证
	# validates_presence_of   :name,          :message => ERROR_EMPTY
	#   validates_presence_of   :email_address, :message => ERROR_EMPTY
	#   validates_presence_of   :password,      :message => ERROR_EMPTY
	#   validates_confirmation_of :password
	#   validates_uniqueness_of :email_address, :message => 'You already have an account.<br>Please log in to your existing account'
	#   validates_length_of     :email_address, :maximum => 255
	#   validates_format_of     :email_address, :with => /^([^@\s]+)@((?:[-a-zA-Z0-9]+\.)+[a-zA-Z]{2,})(\.?)$/, :message => "Please enter a valid email address."

	# with_options(:class_name => 'ERP::SalesOrder', :foreign_key => 'erp_customer_id') do |c|
	#     c.has_many :open_orders, :conditions => 'deleted = false AND completed = false'
	#     c.has_many :close_orders, :conditions => 'deleted = false AND completed = true'
	#   end
  # has_many :contact_people, :foreign_key => "erp_customer_id"
  # has_many :addresses, :foreign_key => "parent_id", :class_name => "ERP::CustomerAddress"

  def self.approve_wine(register)
    wine = Wine.find_or_initialize_by_name_en(register.name_en)
    if wine.new_record?
      wine.update_attributes!(
        :origin_name => register.origin_name,
        :name_zh => register.name_zh,
        :other_cn_name => register.other_cn_name,
        :official_site => register.official_site,
        :wine_style_id => register.wine_style_id,
        :region_tree_id => register.region_tree_id,
        :winery_id => register.winery_id
      )
    end
    return wine
  end

  def get_latest_detail
    details.order("year desc").first
  end

end
