class User < ActiveRecord::Base
  cattr_accessor :current_user
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable, :lockable, :timeoutable, :omniauthable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :username, :avatar_attributes, :profile_attributes

  has_one  :profile, :class_name => 'Users::Profile', :dependent => :destroy
  has_many :albums, :class_name => 'Album', :foreign_key => 'created_by'
  has_many :registers, :class_name => 'Wines::Register'
  has_many :comments, :class_name => 'Wines::Comment'
  has_one  :good_hit_comment, :class_name => 'Users::GoodHitComment'
  has_many :photo_comments
  has_many :photos, :foreign_key => 'business_id', :conditions => { :owner_type => OWNER_TYPE_USER }
  has_one :avatar, :class_name => 'Photo', :foreign_key => 'business_id', :conditions => { :is_cover => true }
  has_one :cellar, :class_name => 'Users::WineCellar'
  has_many :oauths, :class_name => 'Users::Oauth'

  accepts_nested_attributes_for :profile, :avatar, :allow_destroy => true

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

  def role?(value)
    role === value.to_s
  end

  def top_albums count
    count = 0 if count < 0
    Album.all :conditions => { :created_by => id }, :order => 'photos_num DESC', :limit => count
  end

  def oauth_client( sns_name )
    if @client.blank?
      @client = {}
    end

    if @client[ sns_name ].blank?
      tokens = Users::Oauth.first :conditions => { :user_id => id , :sns_name => sns_name.to_s }
      @client[ sns_name ] = OauthChina::Sina.load( tokens )
    end

    @client[ sns_name ]
  end


  def followers
    Friendship.all :conditions => { :user_id => id }
  end

  def followings
    Friendship.all :conditions => { :follower_id => id }
  end

end