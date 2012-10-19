# encoding: utf-8
class EventParticipant < ActiveRecord::Base

  include ::Notificationer::EventNotificationer::Participant

  JOINED_STATUS = 1
  CANCLE_STATUS = 0

  belongs_to :user
  belongs_to :event
  has_one :event_owner, :through => :event, :source => :user
  attr_accessible :cancle_note,
    :email,
    :join_status,
    :note,
    :telephone,
    :username,
    :user_id,
    :people_num

  delegate :username, :to => :user, :prefix => true
  delegate :title, :to => :event, :prefix => true

  validates :people_num, :inclusion => { :in => 1..3 }
  validates :telephone, :username, :user_id, :presence => true
  validates :email, :presence => true, :email_format => true
  validates :cancle_note, :presence => {:if => :do_cancle?}

  after_create :set_event_lock_status
  after_update :udpate_event_lock_status
  after_create :send_join_notification
  after_validation :update_event_participants_count
  after_update :send_cancle_notification, :if => Proc.new{|ep| ep.join_status == CANCLE_STATUS }
  after_update :send_info_changed_notification, :if => Proc.new{ |ep| ep.join_status != CANCLE_STATUS }

  def set_event_lock_status
    if event.set_blocked? # 做限定才去检测
      event.locked! if event.get_participant_number == event.block_in 
    end
  end

  def udpate_event_lock_status
    if event.set_blocked? # 做限定才去检测
      event.unlocked!
    end
  end

  def cancle(params)
    raise "Must Set Key: cancle_note" unless params.has_key? :cancle_note
    update_attributes(:join_status => CANCLE_STATUS, :cancle_note => params[:cancle_note])
    return self
  end

  def joined?
   join_status == JOINED_STATUS
  end

  def cancle?
   join_status == CANCLE_STATUS
  end

  def do_cancle?
   join_status == cancle?
  end

  # 更新活动的参加人数
  # NOTE: 因为人数不一定为一，所以不用counts gem
  def update_event_participants_count
    if new_record?
      Event.update_counters event.id, :participants_count => people_num if joined?
    elsif cancle?
      Event.update_counters event.id, :participants_count => - people_num
    else
      if people_num_changed?
        people_num_change_value = people_num_change[1] - people_num_change[0]
        Event.update_counters event.id, :participants_count => people_num_change_value if joined?
      end
    end
  end

  # 获取发送通知所需的变量: user, event
  def all_stuff
    self.class.includes(:user, :event).where(id)
  end

  #def user
    #if read_attribute(:user).nil?
      #User.new
    #else
      #read_attribute(:user)
    #end
  #end

  # class methods
  class << self
    def get_my_participant_info(event_id, user_id)
     find_by_event_id_and_user_id_and_join_status(event_id, user_id, 1)
    end
  end

end
