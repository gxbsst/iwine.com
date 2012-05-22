# -*- coding: utf-8 -*-
class User < ActiveRecord::Base

 init_resources "Users::Profile", "Users::WineCellar", "Album"
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable, :lockable, :timeoutable, :omniauthable
  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :username, :crop_x, :crop_y, :crop_w, :crop_h, :agree_term
  has_one  :profile, :class_name => 'Users::Profile', :dependent => :destroy
  has_one  :cellar, :class_name => 'Users::WineCellar'
  has_one  :good_hit_comment, :class_name => 'Users::GoodHitComment'
  has_many :albums, :class_name => 'Album', :foreign_key => 'created_by'
  has_many :registers, :class_name => 'Wines::Register'
  has_many :comments, :class_name => "::Comment", :foreign_key => 'user_id', :include => [:user]
  has_many :photo_comments
  has_many :photos #关于用户上传的所有图片
  has_many :images, :as => :imageable # 关于用户的图片
  has_many :oauths, :class_name => 'Users::Oauth'
  has_many :time_events
  has_many :wine_followings, :include => :commentable, :class_name => "Comment", :conditions => {:commentable_type => "Wines::Detail", :do => "follow"}
  has_many :feeds, :class_name => "Users::Timeline", :include => [:ownerable, {:timeline_event => [:actor]}, {:receiverable =>  [:covers, :wine]}], :order => "created_at DESC"
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
  accepts_nested_attributes_for :profile, :allow_destroy => true
  
  # validates :username, :presence => false, :allow_blank => true, :numericality => true
  validates :agree_term, :acceptance => true, :on => :create
  validates :email, :uniqueness => true

  # upload avatar
  mount_uploader :avatar, AvatarUploader

  attr_accessor :crop_x, :crop_y, :crop_w, :crop_h, :agree_term
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

   ##################################
   # 用户资源统计， 如:  藏酒，好友 #
   ##################################

  # 藏酒
  def wine_cellar_count
    ## TODO: 当酒窖未创建时， 会出错， 因此当用户注册帐号时， 请同时创建酒窖、相册等用户资源信息
    cellar.items.count
  end

  # 关注的酒
  def wine_follows_count
    ## TODO 更改用户评论操作之后，更新以下计算代码
    comments.count
  end

  # 关注的酒庄
  def winery_follows_count
    ## TODO: 未实现这个功能， 实现之后请更新
  end

  # 评论
  def comments_count
    comments.count
    ## TODO: 未实现这个功能， 实现之后请更新
  end

  # 酒评
  def detail_comment_count
    ## TODO: 未实现这个功能， 实现之后请更新
  end

  # 关注的人
  def user_followes_count
     followings.count
  end

  # 粉丝
  def user_followeds_count
   
    followers.count
  end

  # 相册
  def albums_count
    albums.count
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

  def all_comments

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
