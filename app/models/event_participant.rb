# encoding: utf-8
class EventParticipant < ActiveRecord::Base
  belongs_to :user
  belongs_to :event
  has_one :event_owner, :through => :event, :source => :user
  attr_accessible :cancle_note, :email, :join_status, :note, :telephone, :username, :user_id

  validates :telephone, :username, :user_id, :presence => true
  validates :email, :presence => true, :email_format => true
  validates :cancle_note, :presence => {:if => :do_cancle?}

  after_create :set_event_lock_status
  after_update :udpate_event_lock_status
  after_create :send_notification_to_owner

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
    update_attributes(:join_status => APP_DATA['event_participant']['join_status']['cancle'],
                      :cancle_note => params[:cancle_note])
    return self
  end

  def joined?
   join_status == APP_DATA['event_participant']['join_status']['joined']
  end

  def cancle?
   join_status == APP_DATA['event_participant']['join_status']['cancle']
  end

  def do_cancle?
   join_status == cancle?
  end

  def send_notification_to_owner
    #TODO:
    #给活动创建者发送死信或者Email
    #event.send_message(user, '我参加这个私信您', '我参加了你这个活动')
    #event.send_email(owner, 'subject', 'body'
  end

  # class methods
  class << self
    def get_my_participant_info(event_id, user_id)
     find_by_event_id_and_user_id(event_id, user_id) 
    end
  end

end
