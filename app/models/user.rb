# -*- coding: utf-8 -*-
# Attributes:
# * id [integer, primary, not null, limit=4] - primary key
# * agree_term [boolean, default=true, limit=1] - TODO: document me
# * albums_count [integer, default=3, limit=4] - TODO: document me
# * authentication_token [string] - Devise Token authenticable module
# * avatar [string] - TODO: document me
# * city [string] - TODO: document me
# * comments_count [integer, default=0, limit=4] - TODO: document me
# * confirmation_sent_at [datetime] - TODO: document me
# * confirmation_token [string] - Devise Confirmable module
# * confirmed_at [datetime] - Devise Confirmable module
# * counts [string] - TODO: document me
# * created_at [datetime, not null] - creation time
# * current_sign_in_at [datetime] - Devise Trackable module
# * current_sign_in_ip [string] - Devise Trackable module
# * email [string, default=, not null]
# * encrypted_password [string, default=, not null] - TODO: document me
# * failed_attempts [integer, default=0, limit=4] - Devise Lockable module
# * followers_count [integer, default=0, limit=4] - TODO: document me
# * followings_count [integer, default=0, limit=4] - TODO: document me
# * last_sign_in_at [datetime] - Devise Trackable module
# * last_sign_in_ip [string] - Devise Trackable module
# * locked_at [datetime] - Devise Lockable module
# * password_salt [string] - Devise Encriptable module
# * photos_count [integer, default=0, limit=4] - TODO: document me
# * remember_created_at [datetime] - Devise Rememberable module
# * reset_password_sent_at [datetime] - Devise Recoverable module
# * reset_password_token [string] - Devise Recoverable module
# * role [string] - TODO: document me
# * sign_in_count [integer, default=0, limit=4] - Devise Trackable module
# * tasting_notes_count [integer, default=0, limit=4] - TODO: document me
# * unconfirmed_email [string] - Devise Confirmable module
# * unlock_token [string] - Devise Locakble module
# * updated_at [datetime, not null] - last update time
# * username [string, default=, not null] - TODO: document me
# * wine_followings_count [integer, default=0, limit=4] - TODO: document me
# * winery_followings_count [integer, default=0, limit=4] - TODO: document me
# * wines_count [integer, default=0, limit=4] - TODO: document me
class User < ActiveRecord::Base

 init_resources "Users::Profile", "Users::WineCellar"
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, 
         :registerable,
         :recoverable, 
         :rememberable, 
         :trackable, 
         :validatable, 
         :confirmable, 
         :lockable, 
         :timeoutable, 
         :omniauthable
  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, 
                  :password,
                  :password_confirmation, 
                  :remember_me, 
                  :username, 
                  :crop_x, 
                  :crop_y, 
                  :crop_w, 
                  :crop_h, 
                  :agree_term,
                  :city,
                  :profile_attributes

  has_one  :profile, 
           :class_name => 'Users::Profile', 
           :dependent => :destroy
  has_one  :cellar, :class_name => 'Users::WineCellar'
  has_many :albums, :foreign_key => 'created_by'
  has_many :registers, :class_name => 'Wines::Register'
  has_many :comments, 
           :class_name => "::Comment", 
           :foreign_key => 'user_id', 
           :include => [:user]

  has_many :photo_comments
  has_many :photos #关于用户上传的所有图片
  has_many :oauths, :class_name => 'Users::Oauth'
  has_many :time_events

  has_many :wine_followings, 
           :include => :commentable,
           :class_name => "Comment", 
           :conditions => {:commentable_type => "Wines::Detail", :do => "follow"}

  has_many :winery_followings, 
           :include => :commentable, 
           :class_name => "Comment", 
           :conditions => {:commentable_type => "Winery", :do => "follow"} 

  has_many :feeds, 
           :class_name => "Users::Timeline", 
           :include => [:ownerable, {:timeline_event => [:actor]}, {:receiverable =>  [:covers, :wine]}], 
           :order => "created_at DESC",
           :conditions => ["receiverable_type = ?", "Wines::Detail"] #TODO: 现在只是调用酒的部分， 如果调用酒庄， 请把include wine去掉， 因为酒庄没有wine

  has_many :followers, :class_name => 'Friendship', :include => :follower do
    def map_user
      map {|f| f.follower }
    end
  end
  has_many :followings, :class_name => 'Friendship', :foreign_key => 'follower_id', :include => :user do
    def map_user
      map {|f| f.user }
    end
  end
  # 推荐的用户
  scope :recommends, lambda { |limit| order("followers_count DESC").limit(limit) }
  accepts_nested_attributes_for :profile, :allow_destroy => true
  
  # validates :username, :presence => false, :allow_blank => true, :numericality => true
  validates :agree_term, :acceptance => true, :on => :create
  validates :email, :uniqueness => true
  validates :city, :presence => true

  # upload avatar
  mount_uploader :avatar, AvatarUploader

  attr_accessor :crop_x, :crop_y, :crop_w, :crop_h, :agree_term, :profile_attributes
  cattr_accessor :current_user

  ## extend message for user
  acts_as_messageable

  ## crop avatar
  after_update :crop_avatar

  def name
    self.to_s
  end

  def mailboxer_email(message)
    email
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
      return if oauth.blank?
      sns_class_name = sns_name.capitalize
      oauth_module = eval( "OauthChina::#{sns_class_name}" )
      @client[ sns_name ] = oauth_module.load( oauth.tokens )
      @client[ sns_name ].instance_eval do
        @sns_user_id = oauth.sns_user_id
      end
    end
    @client[ sns_name ]
  end

  #判断是否和给定得网站绑定
  def check_oauth?(type)
    return self.oauths.where("sns_name = ?", type).first ? true : false
  end

  def available_sns
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

  def remove_followings_from_user data
    users = []

    data.each do |f|
      if !is_following f.id
        users.push( f )
      end
    end

    users
  end

  def following_wines
    Comment.all :conditions => { :user_id => id , :do => 'follow', :commentable_type => 'Wines::Detail' } 
  end

  def remove_followings sns_friends
    users = []

    sns_friends.each do |f|
      if !is_following f.user_id
        users.push( f )
      end
    end

    users
  end
  
  # 判断是否已经关注某人
  def is_following user_id
    Friendship.first :conditions => { :user_id => user_id , :follower_id => id }
  end

  def mail_contacts email, login, password

    if email == 'gmail'
      email_list = []
      data = Contacts::Gmail.new( login , password ).contacts

      data.each do |email|
        email_list.push( email[1] )
      end

      return User.all :conditions => { :email => email_list }

    elsif email == 'sina'
      #TODO
    elsif email == 'qq'
      #TODO
    end

  end

  private

  def resize_avatar(from_version, to_version)
    params =  APP_DATA["image"]["user"]["#{to_version.to_s}"]["width"].to_s << "x" <<  APP_DATA["image"]["user"]["#{to_version.to_s}"]["height"].to_s
    source_path = Rails.root.to_s << "/public" << avatar.url(from_version)
    target_path = Rails.root.to_s << "/public" <<  avatar.url(to_version)
    image = MiniMagick::Image.open(source_path)
    image.resize(params)
    image.write(target_path)
  end

  def crop_avatar
    if crop_x.present?
      avatar.recreate_versions!

      # Crop之后，重新生成缩略图
      resize_avatar(:large, :middle)
      resize_avatar(:large, :thumb)
    end
  end
end
