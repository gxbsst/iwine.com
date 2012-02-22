class Albums < ActiveRecord::Base
    # attr_accessible :user_profiles, :email, :username

    belongs_to :user
    has_many :photos
    has_one  :user_profile
    has_many :user_followers
    # has_many :user_listened
    has_many :user_collects
    has_many :user_posts
    has_many :groups_users
    has_many :groups, :through => :groups_users
    has_many :followers, :class_name => "UserFollower"
    has_many :listens,  :class_name => "UserFollower", :foreign_key => :follower_user_id

    accepts_nested_attributes_for :user_profile
    alias :user_profiles_attribute :user_profile

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

    # Extend and define your user model as you see fit.
    # All of the authentication logic is handled by the
    # parent TwitterAuth::GenericUser class.
    # def self.authenticate(user_name, password)
    # 	user = User.create(:login => 'Weixuhong', :twitter_id => 22)
    # end

end