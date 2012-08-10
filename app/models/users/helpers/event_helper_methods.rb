# encoding utf-8
module Users::Helpers::EventHelperMethods

  module ClassMethods

  end

  module InstanceMethods

    #======= 参加活动 =======#
    
    # 参加活动 
    def join_event(event, params = {})

    end

    # 更新参加活动信息
    def update_join_event_info
      
    end

    # 取消参加
    def cancle_join_event(event)

    end

    # 是否已经参加活动?
    def is_join_event? event
      
    end

    #======= 关注（感兴趣）活动 =======#
    
    # 关注（感兴趣) 活动
    def follow_event event
      
    end

    # 取消关注某个活动
    def cancle_follow_event event
      
    end

    # 判断是否已经关注某个活动
    def is_following_event? event 

    end

  end # end InstanceMethods

  def self.included(receiver)
    receiver.extend         ClassMethods
    receiver.send :include, InstanceMethods
  end
end

