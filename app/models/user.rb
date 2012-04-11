class User < ActiveRecord::Base
  cattr_accessor :current_user
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable, :lockable, :timeoutable, :omniauthable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :username, :crop_x, :crop_y, :crop_w, :crop_h

  has_one  :profile, :class_name => 'Users::Profile', :dependent => :destroy
  has_many :albums, :class_name => 'Album', :foreign_key => 'created_by'
  has_many :registers, :class_name => 'Wines::Register'
  has_many :comments, :class_name => 'Wines::Comment'
  has_one  :good_hit_comment, :class_name => 'Users::GoodHitComment'
  has_many :photo_comments
  has_many :photos, :foreign_key => 'business_id', :conditions => { :owner_type => OWNER_TYPE_USER }
  # has_one  :avatar, :class_name => 'Photo', :foreign_key => 'business_id', :conditions => { :is_cover => true }
  has_one :cellar, :class_name => 'Users::WineCellar'
  
  has_many :oauths, :class_name => 'Users::Oauth'

  has_many :followers, :class_name => 'Friendship', :include => :follower
  has_many :followings, :class_name => 'Friendship', :foreign_key => 'follower_id', :include => :user

  accepts_nested_attributes_for :profile,  :allow_destroy => true

  # validates :username, :presence => false, :allow_blank => true, :numericality => true
  validates :agree_term, :acceptance => true, :on => :create
  validates :email, :uniqueness => true
  
  # upload avatar
  mount_uploader :avatar, AvatarUploader
  
  attr_accessor :crop_x, :crop_y, :crop_w, :crop_h
  after_update :crop_avatar
  
  def crop_avatar
    if crop_x.present?
      avatar.recreate_versions!
    end 
  end
  
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
      oauth = Users::Oauth.first :conditions => { :user_id => id , :sns_name => sns_name.to_s }

      if oauth.blank?
        return
      end

      sns_class_name = sns_name.capitalize
      oauth_module = eval( "OauthChina::#{sns_class_name}" )
      @client[ sns_name ] = oauth_module.load( oauth.tokens )
      @client[ sns_name ].instance_eval do 
        @sns_user_id = oauth.sns_user_id
      end
    end

    @client[ sns_name ]
  end

  def avalible_sns
    list = {} 
    tokens = Users::Oauth.all :conditions => { :user_id => id }
    
    tokens.each do |token|
      list[token[:sns_name]] = token
    end

    list
  end

  def oauth_token( sns_name )
    token = Users::Oauth.first :conditions => { :user_id => id , :sns_name => sns_name }

    if token.blank?
      token = Users::Oauth.new
      token.user_id = id
      token.sns_name = sns_name
    end

    token
  end

  def friends_from_sns sns_name

  end

end
