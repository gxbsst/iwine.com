class Event < ActiveRecord::Base
  belongs_to :user
  belongs_to :region
  belongs_to :audit_log
  has_many :photos, :as => :imageable
  has_many :wines, :class_name => "EventWine"
  has_many :participants, :class_name => "EventParticipant"
  has_many :invitees, :as => :invitable, :class_name => "EventInvitee"
  has_many :comments,  :class_name => 'EventComment', :as => :commentable
  has_many :follows, :as => :followable, :class_name => "EventFollow"

  attr_accessible :address, :begin_at, :block_in, :description, :end_at, :followers_count,
  :latitude, :longitude, :participants_count, :poster, :publish_status, :title,
  :crop_x, :crop_y, :crop_w, :crop_h, :region_id, :tags, :tag_list

  attr_accessor :crop_x, :crop_y, :crop_w, :crop_h

  validates :title, :tag_list, :address, :begin_at, :end_at,  :presence => true

  acts_as_taggable
  acts_as_taggable_on :tags

  # process address longitude & latitude
  geocoded_by :address

  # Upload Poster 
  mount_uploader :poster, PosterUploader

  # 设置封面的尺寸 
  before_save :set_geometry

  # Crop poster
  after_update :crop_poster

  # 统计
  counts :participants_count => {
    :with => "EventParticipant",
    :receiver => lambda {|participant| participant.event },
    :increment => {:on => :create},
    :decrement => {
    :on => :update,  
    :if => lambda {|participant| participant.cancle? }}                              
  },
    :followers_count => {:with => "Follow", 
      :receiver => lambda {|follow| follow.followable },
      :increment => {
    :on => :create, 
    :if => lambda {|follow| follow.follow_counter_should_increment_for("Event")}},
       :decrement => {
    :on => :destroy, 
    :if => lambda {|follow| follow.follow_counter_should_decrement_for("Event")}}                              
  }

  # 将活动锁定
  def locked!
    update_attribute(:publish_status,  APP_DATA['event']['publish_status']['locked'])
  end

  # 活动是否可参加
  def joinedable?
    if locked? || draft? || cancle? || timeout?
      false 
    else
      true 
    end
  end

  # 活动是否设定人数
  def set_blocked?
    block_in > 0 ? true : false
  end

  # 人数已经订满?
  def ausgebucht?
    return false  unless set_blocked?
    block_in > get_participant_number ? false : true
  end

  # 获取参加活动的人数
  def get_participant_number
    EventParticipant.where(:event_id => id, 
                           :join_status =>  APP_DATA['event_participant']['join_status']['cancle']).count 
  end

  # 是否已经被关注
  def have_been_followed?(user_id)
    Follow.get_my_follow_item(self.class.to_s, id, user_id) 
  end

  # 是否已经参加
  def have_been_joined?(user_id)
    EventParticipant.get_my_participant_info(id, user_id)
  end

  # 邀请用户参加活动
  def invite_one_user(inviter_id, invitee_id, params = {})
    return if (have_been_invited?(invitee_id) || !joinedable?)

    invitee = invitees.build(:inviter_id => inviter_id,
                             :invitee_id => invitee_id,
                             :invite_log => params[:invite_log])
    invitee.save
    #TODO: Send Message OR Email
    return invitee
  end

  # 用户是否已经被邀请
  def have_been_invited? invitee_id
    ::EventInvitee.check_exist?(self.class.to_s, id, invitee_id).present?
  end

  # 活动是否已经过期
  def timeout?
    Time.now > begin_at
  end

  # 活动状态是否意见被锁定
  def locked?
    publish_status == APP_DATA['event']['publish_status']['locked'] 
  end

  # 活动状态是否为抄稿
  def draft?
    publish_status == APP_DATA['event']['publish_status']['draft'] 
  end

  # 活动状态是否为取消
  def cancle?
    publish_status == APP_DATA['event']['publish_status']['cancle'] 
  end

  # 添加某只酒到活动
  def add_one_wine(wine_detail_id)
   return if wine_have_been_added? wine_detail_id
   wine = wines.build(:wine_detail_id => wine_detail_id) 
   wine.save
   wine
  end

  # 检查某支酒是否已经被添加
  def wine_have_been_added? wine_detail_id
   EventWine.check_wine_have_been_added?(id, wine_detail_id)
  end

  # 活动标签 
  def tags_array
    tags.collect {|tag| {:id => tag.id, :name => tag.name}}
  end

  private
  def set_geometry
    geometry = self.poster.large.geometry
    if (! geometry.nil?)
      self.poster_width = geometry[:width]
      self.poster_height = geometry[:height]
    end
  end

  def resize_poster(from_version, to_version)
    source_path = Rails.root.to_s << "/public" << poster.url(from_version)
    target_path = Rails.root.to_s << "/public" << poster.url(to_version)
    image = MiniMagick::Image.open(source_path)
    image.resize(get_poster_resize_params(to_version))
    image.write(target_path)
  end

  def crop_poster
    if crop_x.present?
      poster.recreate_versions!
      resize_poster(:large, :middle)
      resize_poster(:large, :thumb)
      resize_poster(:large, :x_thumb)
    end
  end

  def get_poster_resize_params(version)
    APP_DATA["image"]["poster"]["#{version.to_s}"]["width"].to_s << 
    "x" <<  APP_DATA["image"]["poster"]["#{version.to_s}"]["height"].to_s
  end
end

