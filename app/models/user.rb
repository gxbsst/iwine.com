# -*- coding: utf-8 -*-
class User < ActiveRecord::Base

  acts_as_voter

  include Users::UserSupport
  include Users::SnsOauth
  init_resources "Users::Profile", "Users::WineCellar"

  cattr_accessor :current_user
  attr_accessor :crop_x, 
                :crop_y, 
                :crop_w, 
                :crop_h, 
                :agree_term, 
                :profile_attributes,
                :current_password

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
                  :profile_attributes,
                  :current_password

  devise :database_authenticatable,
         :registerable,
         :recoverable,
         :rememberable,
         :trackable,
         :validatable,
         :confirmable,
         :lockable,
         :timeoutable,
         :omniauthable,
         :token_authenticatable

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
  has_many :timeline_events, :as => :actor
  has_many :wine_followings,
           :include => :followable,
           :class_name => "Follow",
           :conditions => {:followable_type => "Wines::Detail"}
  has_many :winery_followings,
           :include => :followable,
           :class_name => "Follow",
           :conditions => {:followable_type => "Winery"}

  has_many :feeds,
    :class_name => "Users::Timeline",
    :include => [:ownerable, {:timeline_event => [:actor]}, {:receiverable =>  [:covers]}],
    :order => "created_at DESC",
    :group => 'receiverable_id'
    # :conditions => ["receiverable_type = ?", "Wines::Detail"] 
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
  has_many :follows, :include =>[:user]
  has_many :events, :order => 'created_at DESC'
  has_many :notes

  # 推荐的用户
  # default_scope where('sign_in_count > 0 and confirmation_token is null')
  scope :active_user, where('sign_in_count > 0 and confirmation_token is null')
  scope :recommends, lambda { |limit| active_user.order("followers_count DESC").limit(limit) }
  scope :no_self_recommends, lambda {|limit, user_id| recommends(limit).where("id != ?", user_id)}
  accepts_nested_attributes_for :profile, :allow_destroy => true

  # validates :username, :presence => false, :allow_blank => true, :numericality => true
  validates :agree_term, :acceptance => true, :on => :create
  validates :email, :username, :uniqueness => true
  validates :username, :presence => true
  # validates :city, :presence => true, :on => :update
  # validates :current_password, :presence => true
  validates_confirmation_of :password
  validates :domain, 
            :uniqueness => true,
            :length => { :maximum => 30 },
            :format => { :with => /^[a-zA-Z\-_\d]+$/},
            :allow_blank => true

  ## crop avatar
  after_update :crop_avatar

  # upload avatar
  mount_uploader :avatar, AvatarUploader

  # extend message for user
  acts_as_messageable

  # Friendly Url
  extend FriendlyId
  friendly_id :pretty_url, :use => [:slugged]

  alias_method :friends, :followers
  counts :comments_count => {
          :with => "Comment",
          :receiver => lambda {|comment| comment.user },
          :increment => {
            :on => :create, 
            :if => lambda {|comment| comment.comments_counter_should_increment? }},
          :decrement => {
            :on => :save,  
            :if => lambda {|comment| comment.comments_counter_should_decrement? }}
         },
         :wines_count => {
          :with => "Users::WineCellarItem",
          :receiver => lambda {|cellar_item| cellar_item.user},
          :increment => {:on => :create},
          :decrement => {:on => :destroy}
         },   
         :photos_count => {
          :with => "Photo",
          :receiver => lambda {|photo| photo.user}, 
          :increment => {
           :on => :create, 
           :if => lambda {|photo| photo.album_id > 0}},
          :decrement => {
           :on => :save,
           :if => lambda {|photo| !photo.deleted_at.blank? && photo.album_id > 0 }}
         },  
         :wine_followings_count => {
          :with => "Follow",
          :receiver => lambda {|follow| follow.user }, 
          :increment => {
           :on => :create,  
           :if => lambda{|follow| follow.follow_counter_should_increment_for("Wines::Detail")}},
          :decrement => {
           :on => :destroy, 
           :if => lambda{|follow| follow.follow_counter_should_decrement_for("Wines::Detail")}}
         }, 
         :winery_followings_count => {
           :with => "Follow",
           :receiver => lambda {|follow| follow.user }, 
           :increment => {
            :on => :create, 
            :if => lambda{|follow| follow.follow_counter_should_increment_for("Winery")}},
           :decrement => {
            :on => :destroy, 
            :if => lambda{|follow| follow.follow_counter_should_decrement_for("Winery")}}
         }, 
         :followers_count =>  {
           :with => "Friendship",
           :receiver => lambda {|friendship| friendship.user },
           :increment => {:on => :create},
           :decrement => {:on => :destroy}
         }, 
         :followings_count => {
           :with => "Friendship",
           :receiver => lambda {|friendship| friendship.follower },
           :increment => {:on => :create},
           :decrement => {:on => :destroy}
         },   
         :albums_count => {
           :with => "Album",
           :receiver => lambda {|album| album.user }, 
           :increment => {:on => :create},
           :decrement => {:on => :destroy}
         }

  def domain=(value)
    if self.domain.present?
      write_attribute(:domain, self.domain)
    else
      write_attribute(:domain, value)
    end
  end

  def pretty_url
    if domain.present?
      domain
    else
      (id + 10000) if  id.present? # 用户以10000开始
    end
  end

  def name
    self.to_s
  end

  def mailboxer_email(message)
    email
  end

  def role?(value)
    role === value.to_s
  end

  def top_albums count
    count = 0 if count < 0
    Album.all :conditions => { 
      :created_by => id }, 
      :order => 'photos_num DESC', 
      :limit => count
  end

  def oauth_client( sns_name )
    if @client.blank?
      @client = {}
    end

    if @client[ sns_name ].blank?
      oauth = Users::Oauth.first :conditions => { 
        :user_id => id ,
        :sns_name => sns_name.to_s }
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
    return self.oauths.oauth_binding.where("sns_name = ?", type).first ? true : false
  end

  def available_sns
    list = {}
    tokens = Users::Oauth.oauth_binding.all :conditions => { :user_id => id }

    tokens.each do |token|
      list[token[:sns_name]] = token
    end

    list
  end

  def oauth_token( sns_name )
    token = Users::Oauth.first :conditions => {
      :user_id => id , 
      :sns_name => sns_name }
    if token.blank?
      token = Users::Oauth.new
      token.user_id = id
      token.sns_name = sns_name
    end
    token
  end

  def following_wines
    Comment.all :conditions => { 
      :user_id => id , 
      :do => 'follow', 
      :commentable_type => 'Wines::Detail' }
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

  def has_no_password?
    self.encrypted_password.blank?
  end

  # 当用户激活帐号， 发送Welcome Email
  def confirm!
    UserMailer.welcome_alert(self).deliver
    super
  end

  #检查是否和user2有过私信会话， 如果有会话则返回conversation
  def has_conversation_with?(user2)
    current_conversation = nil
    mailbox.conversations.each do |c|
      receipts = c.receipts_for user2
      if receipts.present?
        current_conversation = c
        break
      end
    end
    return current_conversation
  end

  def domain_url
    "http://iwine.com/users/#{domain}"
  end

  def has_oauth_item?(params)
    Users::Oauth.where(
      ["user_id = ? AND sns_name= ? AND sns_user_id = ?", 
        id, params[:sns_name], params[:sns_user_id]]).present?
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
