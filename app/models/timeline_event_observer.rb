# -*- coding: utf-8 -*-
class TimelineEventObserver < ActiveRecord::Observer

  def after_create(timeline_event)
    if timeline_event.secondary_actor_type == "Wines::Detail" # 当用户对酒做动作时
      # User Followers
      user = timeline_event.actor
      followers = user.followers.map{|i| i.user }
      create_timelines(followers,
                       timeline_event,
                       :ownerable_type => "User",
                       :receiver => "Wines::Detail" ) if followers.size > 0
      # Wine Follwers
      wine_detail = timeline_event.secondary_actor
      # 如果这支酒和这个动作已经存在
      followers = wine_detail.followers
      create_timelines(followers, timeline_event,
                       :ownerable_type => "Wines::Detail",
                       :receiver => "Wines::Detail" ) if followers.size > 0
    elsif timeline_event.secondary_actor_type =="Winery" # 当用户对酒庄发生动作时
      # User Followers
      user = timeline_event.actor
      followers = user.followers.map{|i| i.user }
      create_timelines(followers, timeline_event,
                       :ownerable_type => "User",
                       :receiver => "Winery" ) if followers.size > 0
      # Winery Follwers
      winery = timeline_event.secondary_actor
      followers = winery.followers
      create_timelines(followers, timeline_event,
                       :ownerable_type => "Winery",
                       :receiver => "Winery" ) if followers.size > 0
    else  # 当用户对其他(不包括酒和酒庄)做动作时候
      user = timeline_event.actor
      followers = user.followers.map{|i| i.user }
      create_timelines(followers, timeline_event,
                       :ownerable_type => "User",
                       :receiver => "User" ) if followers.size > 0
    end
  end

  private
  def create_timelines(users, event, opts = { })
    users.each do |user|
      items = Users::Timeline.
        receiver_item(user.id, event.event_type, opts[:receiver], event.secondary_actor_id)
      if items.count > 0
        items.first.update_attribute(:updated_at, Time.now)
      else
      create_options = {:user_id => user.id,
        :timeline_event_id => event.id,
        :ownerable_id => event.secondary_actor.id,
        :receiver_id => event.secondary_actor.id,
        :event_type => event.event_type
      }.merge!(opts)
      Users::Timeline.create!(create_options)
      end
    end
  end

end
