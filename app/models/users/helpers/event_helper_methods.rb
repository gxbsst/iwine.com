# encoding utf-8
module Users::Helpers::EventHelperMethods

  module ClassMethods

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
      rails ::EventException::HaveJoinedEvent if event.have_been_joined? id
      return false unless event.joinedable?
      participant = event.participants.build(participant_info)
      participant.save
      participant
    end

    # 更新参加活动信息
    # participant: object
    # info: hash
    def update_join_event_info(participant, info)
     event = participant.event
     return false if event.locked?
     participant.update_attributes(info)
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

    
  end # end InstanceMethods

  def self.included(receiver)
    receiver.extend         ClassMethods
    receiver.send :include, InstanceMethods
  end
end

