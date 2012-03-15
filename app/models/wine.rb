class Wine < ActiveRecord::Base

  has_many :details, :class_name => '::Wines::Detail'
  belongs_to :winery
  belongs_to :style, :class_name => "::Wines::Style", :foreign_key => "wine_style_id"
  belongs_to :region, :class_name => "::Wines::Region", :foreign_key => "region_tree_id"

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
  
end
