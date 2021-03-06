# encoding utf-8
module Users::Helpers::EventHelperMethods

  module ClassMethods
    #has_many :create_events, :class => 'Event', :order => 'created_at DESC'
    #has_many :join_events, :class => 'EventParticipant', :include 
    #has_many :follow_events, :as => :followable, :class_name => "EventFollow"
  end

  module InstanceMethods

    #======= 参加活动 =======#

    # 参加活动
    # params:
    #  event: object
    #  participant_info: hash 
    # return:
    #  participant object
    def join_event(event, participant_info = {})
      value = {:user_id => id }
      participant_info.merge! value
      raise ::EventException::HaveJoinedEvent if event.have_been_joined? id
      raise ::EventException::ErrorPeopleNum, event.get_joinable_num if people_num_error(event, participant_info['people_num'])
      return false unless event.joinedable?
      participant = event.participants.build(participant_info)
      participant.save
      participant
    end

    # 更新参加活动信息
    # participant: object
    # info: hash
    def update_join_event_info(participant, info)
     param = {:join_status => ::EventParticipant::JOINED_STATUS}
     event = participant.event
     people_num_change = info['people_num'].to_i - participant.people_num
     raise ::EventException::ErrorPeopleNum, event.get_joinable_num  if people_num_error(event, people_num_change)
     return false if event.locked?
     participant.update_attributes(info, info.merge!(param))
     participant
    end

    # 取消参加
    def cancle_join_event(event, params)
      participant = EventParticipant.get_my_participant_info(event.id, id)
      rails ::EventException::HaveNoJoinedEvent unless participant
        participant.cancle(params)  
    end

    #======= 关注（感兴趣）活动 =======#

    # 关注（感兴趣) 活动
    def follow_event event
      raise ::EventException::HaveFollowedEvent if event.have_been_followed? id
      @follow = event.follows.build
      @follow.user_id = id
      @follow.save
    end

    # 取消关注某个活动
    def cancle_follow_event event
      raise ::EventException::HaveNoFollowedEvent unless event.have_been_followed? id
      @follow = ::Follow.get_my_follow_item("Event", event.id, id) 
      @follow.destroy
    end

    #======= 邀请好友参加活动 =======#

    # 邀请一个用户
    def invite_one(invitee_id, event, params = {})
     invitee =  event.invite_one_user(id, invitee_id, params)
    end

    # 判定某个用户是否是活动的拥有者
    def is_owner_of_event? event
     event.user == self ? true : false
    end

    # 创建的活动总数
    def create_events_count
      Event.with_create_for_user(id).count
    end

    # 参加的活动总数
    def join_events_count
      Event.with_participant_for_user(id).count
    end

    # 感兴趣的活动总数
    def follow_events_count
      Event.with_follow_for_user(id).count
    end

    # 活动总和
    def events_count
      create_events_count + join_events_count + follow_events_count
    end

    # 创建的活动
    def create_events(limit = 3)
      Event.with_create_for_user(id).limit(limit)
    end

    # 参加的活动
    def join_events(limit = 3)
      Event.with_participant_for_user(id).limit(limit)
    end

    # 感兴趣的活动
    def follow_events(limit = 3)
      Event.with_follow_for_user(id).limit(limit)
    end

    def get_participant_item(event)
     event.have_been_joined?(id)
    end

    def get_follow_item(event)
      event.have_been_followed? id
    end

    # 判断活动人数加上当前报名人数是否合法
    def people_num_error(event, people_num)
      #block_in = (event.block_in.blank? ? 0 : event.block_in)
      if event.set_blocked?
        event.block_in < (event.participants_count + people_num.to_i)
      else
       false
      end
    end

  end # end InstanceMethods

  def self.included(receiver)
    receiver.extend         ClassMethods
    receiver.send :include, InstanceMethods
  end
end

