# -*- coding: utf-8 -*-
class TimelineEventObserver < ActiveRecord::Observer

  def after_create(timeline_event)
    # User Followers
    user = timeline_event.actor
    followers = user.followers.map_user
    create_timelines(followers, timeline_event,
                     :ownerable_type => timeline_event.actor_type,
                     :receiverable_type => timeline_event.secondary_actor_type ) if followers.size > 0
    
    # Wine || Winery || Event
    receiver  =  timeline_event.secondary_actor
    followers = receiver.followers
    create_timelines(followers, timeline_event,
                      :ownerable_type => timeline_event.secondary_actor_type,
                      :receiverable_type => timeline_event.secondary_actor_type ) if followers.size > 0      
  end

  private
  def create_timelines(followers, event, opts = { })
    # 如果Ownerable == User
    if opts[:ownerable_type] == "User"
      followers.each do |user|   
        create_options = {:user_id => user.id,
          :timeline_event_id => event.id,
          :ownerable_id => event.actor.id,
          :receiverable_id => event.secondary_actor.id, # 酒或者酒庄或者或者活动等ID
          :event_type => event.event_type
          }.merge!(opts)
        Users::Timeline.create!(create_options) 
      end    
    else # 酒或者酒庄或者活动等
      followers.each do |user|
        items = Users::Timeline.
        receiver_item(user.id, event.event_type, opts[:receiverable_type], event.secondary_actor_id)
        # 判断该条目已经存在， 如果存在则更新updated_at
        if items.count > 0
          items.first.update_attribute(:updated_at, Time.now)
        else
          create_options = {:user_id => user.id,
            :timeline_event_id => event.id,
            :ownerable_id => event.secondary_actor.id,
            :receiverable_id => event.secondary_actor.id, # 酒或者酒庄或者或者活动等ID
            :event_type => event.event_type
            }.merge!(opts)
            Users::Timeline.create!(create_options)
          end # end if count > 0 
        end
      end # end if opts[:ownerable_type] == "User"
    end

end
