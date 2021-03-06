# encoding: utf-8
class Event < ActiveRecord::Base

  include ::Notificationer::EventNotificationer

  CANCLED_STATUS = 0
  DRAFTED_STATUS = 1
  PUBLISHED_STATUS = 2
  LOCKED_STATUS = 3
  CITY = { '上海' => 1,  '成都' => 2, '北京' => 3, '深圳' => 4, '广州' => 5, '其他' => '6'}

  belongs_to :user
  belongs_to :region
  belongs_to :audit_log

  has_many :photos, :as => :imageable
  has_many :wines, :class_name => "EventWine"
  has_many :participants, :class_name => "EventParticipant", :include => [:user], :conditions => "join_status = #{::EventParticipant::JOINED_STATUS}"
  has_many :invitees, :as => :invitable, :class_name => "EventInvitee"
  has_many :comments,  :class_name => 'EventComment', :as => :commentable
  has_many :follows, :as => :followable, :class_name => "EventFollow"

  attr_accessible :address, :begin_at, :block_in, :description, :end_at, :followers_count,
  :latitude, :longitude, :participants_count, :poster, :publish_status, :title,
  :crop_x, :crop_y, :crop_w, :crop_h, :region_id, :tags, :tag_list

  attr_accessor :crop_x, :crop_y, :crop_w, :crop_h

  validates :title, :tag_list, :address, :begin_at, :end_at,  :presence => true
  validates :publish_status, :inclusion => { :in => [0,1,2,3] }
  validate :begin_at_be_before_end_at
  validate :begin_at_be_after_now
  validates :block_in, :numericality => {:allow_blank => true}
  #, :exclusion => {:in => [0]}

  scope :published, where(:publish_status => PUBLISHED_STATUS ).order("begin_at ASC")
  scope :cancle, where(:publish_status => CANCLED_STATUS ).order("begin_at ASC")
  scope :live, published.where( "begin_at > ?", Time.now ) # 未举行
  scope :recommends, lambda {|limit| live.order('participants_count DESC').limit(limit) }  # 推荐
  scope :recent_week, where(['begin_at >= ? AND begin_at <= ?', Time.current, Time.current + 1.week])
  scope :weekend, published.where(['begin_at >= ? AND begin_at <= ?',
                        Time.current.end_of_week - 2.day, Time.current.end_of_week])
  scope :date_with, lambda { |date| published.live.where(["begin_at >= ? AND begin_at <= ?",
                                          date, date + 1.day]) }
  scope :city_with, lambda { |city| where(["region_id = ?", CITY[city]]) }
  # 用户参加的活动
  scope :with_participant_for_user, lambda{|user_id|joins(:participants).
    where(["event_participants.user_id = ? AND event_participants.join_status =?",
          user_id, ::EventParticipant::JOINED_STATUS]).
          order('begin_at')}
  # 用户感兴趣的活动
  scope :with_follow_for_user, lambda{|user_id|joins(:follows).
    where(["follows.user_id = ?", user_id]).order('begin_at')}
  # 用户创建的活动
  scope :with_create_for_user, lambda{|user_id| where(:user_id => user_id).order('created_at DESC')}

  acts_as_taggable
  acts_as_taggable_on :tags

  # messageable
  acts_as_messageable

  # process address longitude & latitude
  geocoded_by :full_address
  after_create :get_coordinates

  def get_coordinates
    Delayed::Job.enqueue GoogleMapsCoordinateService.new(self)
  end

  # Upload Poster
  mount_uploader :poster, PosterUploader

  # 设置封面的尺寸
  before_save :set_geometry

  # Crop poster
  after_update :crop_poster

  # 发送取消活动通知
  after_save :send_cancle_event_notification, :if => Proc.new {|event| event.cancle? && event.participants_count > 0}
  after_update :send_update_event_notification, :if => Proc.new {|event| !event.cancle? && event.participants_count > 0}

  # CUSTOM VALIDATE
  # 活动开始时间应该大于结束时间
  def begin_at_be_before_end_at
    if begin_at.present?
      errors.add(:end_at, "结束时间必须大于开始时间") if self.begin_at > self.end_at
    end
  end

  # 活动开始时间应该大于结束时间
  def begin_at_be_after_now
    if end_at.present?
      errors.add(:end_at, "请输入有效的结束时间") if self.end_at < Time.now
    end
  end

  # 统计
  counts :followers_count => {:with => "Follow",
            :receiver => lambda {|follow| follow.followable },
            :increment => {
              :on => :create,
              :if => lambda {|follow| follow.follow_counter_should_increment_for("Event")}},
            :decrement => {
              :on => :destroy,
              :if => lambda {|follow| follow.follow_counter_should_decrement_for("Event")}}
         },
         :comments_count => {:with => "Comment",
            :receiver => lambda {|comment| comment.commentable },
            :increment => {:on => :create, :if => lambda {|c| c.counter_should_increment_for("Event") }},
            :decrement => {:on => :save,   :if => lambda {|c| c.counter_should_decrement_for("Event") }}
         },
         :photos_count   => {:with => "AuditLog",
            :receiver => lambda {|audit_log| audit_log.logable.imageable },
            :increment => {
              :on => :create,
              :if => lambda {|audit_log| audit_log.image_should_increment?('Event')}},
            :decrement => {
              :on => :save,
              :if => lambda {|audit_log| audit_log.image_should_decrement?('Event')}}
         }


  # 将活动锁定
  def locked!
    update_attribute(:publish_status,  ::Event::LOCKED_STATUS)
  end

  #用于将海报分享到第三方网站
  def share_name
    "【#{user.username}】发起的《#{title}》活动"
  end

  # 将活动解除锁定
  def unlocked!
    update_attribute(:publish_status,  ::Event::PUBLISHED_STATUS) if locked?
  end

  # 活动是否可参加
  def joinedable?
    if locked? || draft? || cancle? || timeout? || ausgebucht?
      false
    else
      true
    end
  end

  # 活动是否设定人数
  def set_blocked?
    #block_in.blank? ? false : true
    block_in > 0 ? true : false
  end

  def block_in
    value = read_attribute(:block_in)
    value.blank? ? 0 : value
  end

  # 人数已满
  def ausgebucht?
    return false  unless set_blocked?
    (block_in <= get_participant_number)? true: false
  end

  # 获取参加活动的人数
  def get_participant_number
    participants_count
  end

  # 获取可参加活动活动的名额
  def get_joinable_num
    block_in - participants_count
  end

  # 是否已经被关注
  def have_been_followed?(user_id)
    Follow.get_my_follow_item(self.class.to_s, id, user_id)
  end

  # 是否已经参加
  def have_been_joined?(user_id)
    EventParticipant.get_my_participant_info(id, user_id)
  end

  # 是否已经取消参加
  def have_been_cancle_joined?(user_id)
    ep = have_been_joined?(user_id)
    if ep
      ep.join_status == 0 ? true : false
    end
  end

  # 邀请用户参加活动
  def invite_one_user(inviter_id, invitee_id, params = {})
    return if (have_been_invited?(invitee_id))

    invitee = invitees.build(:inviter_id => inviter_id,
                             :invitee_id => invitee_id,
                             :invite_log => params[:invite_log])
    invitee.save
    #TODO: Send Message OR Email
    invitee
  end

  # 用户是否已经被邀请
  def have_been_invited? invitee_id
    ::EventInvitee.check_exist?(self.class.to_s, id, invitee_id).present?
  end

  # 活动是否已经过期
  def timeout?
    Time.now > end_at if published?
  end

  # 活动状态是否意见被锁定
  def locked?
    publish_status == LOCKED_STATUS
  end

  # 活动状态是否为抄稿
  def published?
    publish_status == PUBLISHED_STATUS
  end

  def published!
    if cancle?
      raise ::EventException::EventHaveCancled.new('该活动已经被取消')
    else
      if poster.blank?
        errors.add(:poster,'海报不能为空')
        raise "海报不能为空"
      else
        if self.valid?
          update_attribute(:publish_status, PUBLISHED_STATUS)
        else
          raise "不合格的数据"
        end
      end
    end
  end

  # 活动状态是否为抄稿
  def draft?
    publish_status == DRAFTED_STATUS
  end

  def draft!
    if cancle?
      raise ::EventException::EventHaveCancled.new('该活动已经被取消')
    elsif published?
      raise ::EventException::EventHavePublished.new('活动已经发布了,不能变草稿')
    else
      update_attribute(:publish_status, DRAFTED_STATUS)
    end
  end

  # 活动状态是否为取消
  def cancle?
    publish_status == CANCLED_STATUS
  end

  def cancle!
    if cancle?
      raise ::EventException::EventHaveCancled.new('该活动已经被取消')
    else
      update_attribute(:publish_status, CANCLED_STATUS)
    end
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

  def full_address
    "#{city}  #{address}"
  end

  def begin_end_at
   begin_at.to_s(:yt) + " - " + end_at.to_s(:yt)
  end

  def begin_end_at_with_cn
   begin_at.to_s(:cn_short) << "至" << end_at.to_s(:cn_short)
  end
  
  def begin_end_at_cn
    begin_at.to_s(:cn_yt) << " 至 " << end_at.to_s(:cn_yt)
  end
  # 是否已经感兴趣活动
  # 这个方法重复定义, 但是为了和酒庄／酒相同，这里重复定义
  def is_followed_by? (user)
    have_been_followed? user.id
  end

  def city
   cities = CITY
   cities.inject({}){|m,(k,v)| m.merge({v => k})}[region_id]
  end

  # 活动是否可编辑
  def editable?
     (timeout? || cancle?) ? false : true
  end

  # 活动是否可取消
  def cancleable?
     (timeout? || cancle?) ? false : true
  end

 class << self
   def get_date_time(params_date)
     date = params_date
     if date == "today" # 今天
       date_time = Date.current
     elsif date == "tomorrow" # 明天
       date_time = Date.tomorrow
     else
       date_time = Time.parse(date) # 其他时间
     end
     date_time
   end

   def search(params)
     events = Event.published
     if params[:tag].present? # TAG
       events = events.tagged_with(params[:tag]).order("created_at DESC")
     elsif params[:city].present?
       events = events.city_with(params[:city])
     elsif params[:date].present? # DATE
       if params[:date] == 'recent_week' # 最近一周
         events = events.recent_week
       elsif params[:date] == 'weekend' # 周末
         events = events.weekend
       else
         date_time = get_date_time(params[:date])
         events = events.date_with(date_time)
       end
     elsif params[:city].present? # CITY
       events = events.city_with(params[:city])
     elsif params[:word].present?   # 使用 lucene
       search = HotSearch.new
       events = search.search_event(params['word'])
     end
     events
   end

 end

 private

 def set_geometry
   geometry = self.poster.large.geometry
   if(!geometry.nil?)
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

 ## 当活动被取消时， 发通知给活动参与者
 #def send_cancle_event_notification
 #  receivers = self.participants(&:user)
 #
 #  # TODO: IAN 确定最终模板
 #  subject = '活动取消'
 #  body = '您参加的活动被取消了'
 #
 #  delay.send_system_message(receivers, body, subject)
 #end

end

