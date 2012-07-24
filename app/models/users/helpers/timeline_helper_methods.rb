
module Users::Helpers::TimelineHelperMethods

  module ClassMethods

  end

  module InstanceMethods
    # 当关注某人时， 可以压入该用户的events到当前用户的Timline中
    def push_one_user_events(user, events)
      events = user.timeline_events
      unless events.blank?
        events.each do |event|
          user_timeline = Users::Timeline.create(
            :user_id           => id,
            :timeline_event_id => event.id,
            :ownerable_type    => event.actor_type, # 谁做(User)
            :ownerable_id      => event.actor_id,
            :receiverable_type => event.secondary_actor_type, # 谁被做（Wine, Winery)
            :receiverable_id   => event.secondary_actor_id,
            :event_type        => event.event_type,
            :created_at        => event.created_at,
            :updated_at        => event.updated_at)
        end # end events
      end # end unless
    end

    # 将酒或者酒庄压入某个用户的Timeline
    def push_one_event_item(user, event)
      user_timeline = Users::Timeline.create(
        :user_id           => user.id,
        :timeline_event_id => event.id,
        :ownerable_type    => event.actor_type, # 谁做(User)
        :ownerable_id      => event.actor_id,
        :receiverable_type => event.secondary_actor_type, # 谁被做（Wine, Winery)
        :receiverable_id   => event.secondary_actor_id,
        :event_type        => event.event_type,
        :created_at        => event.created_at,
        :updated_at        => event.updated_at)
    end

    # 当用户第一次注册成功，初始化用户的首页数据
    def init_events_from_followings
      # 关注用户的Timeline
      users = followings.map_user
      users.each do |user|
        events = user.timeline_events
        push_one_user_events(user, events) unless events.blank?
      end # end users

      # 关注的酒Timeline
      wines = wine_followings
      wines.each do |wine|
        if timeline_wine = TimelineEvent.where(
          :secondary_actor_type => "Wines::Detail", 
          :secondary_actor_id => wine.id).first
          push_one_event_item(self, timeline_wine)
        end
      end

      # 关注的酒庄Timeline
      wineries = winery_followings
      wines.each do |wine|
        if timeline_wine = TimelineEvent.where(
          :secondary_actor_type => "Winery", 
          :secondary_actor_id => wine.id).first
          push_one_event_item(self, timeline_wine)
        end
      end
    end

  end # end InstanceMethods

  def self.included(receiver)
    receiver.extend         ClassMethods
    receiver.send :include, InstanceMethods
  end
end

