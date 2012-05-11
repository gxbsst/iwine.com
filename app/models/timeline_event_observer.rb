class TimelineEventObserver < ActiveRecord::Observer
  
  def after_create(timeline_event)
    if timeline_event.actor_type == "User" && timeline_event.secondary_actor_type == "Wines::Detail"
      
      # Both Wine && User    
      # Find Actor's followers, will be followers of  user & Wine
      # User Followers 
      user = timeline_event.actor
      followers = user.followers.map{|i| i.user }
      
      create_timelines(followers, timeline_event, "User") if followers.size > 0
      
      # Wine Follwers
      
      wine_detail = timeline_event.secondary_actor
      wine_followers = wine_detail.followers
      create_timelines(wine_followers,timeline_event, "Wine::Detail") if wine_followers.size > 0
      
    elsif timeline_event.actor_type == "User" && timeline_event.secondary_actor_type.nil?
      
      # Just For User
      # User Followers 
      user = timeline_event.actor
      followers = user.followers.map{|i| i.user }
      create_timelines(followers, timeline_event, "User") if followers.size > 0
      
    elsif timeline_event.actor_type.nil? && timeline_event.secondary_actor_type == "Wines::Detail"
      # Just For Wine Follwers
      wine_detail = timeline_event.secondary_actor
      wine_followers = wine_detail.followers
      create_timelines(wine_followers, timeline_event, "Wine::Detail") if wine_followers.size > 0
    end
  end
  
  private
  def create_timelines(users, event, about_with)
    users.each do |user|
      Users::Timeline.create!(:user_id => user.id, 
        :timeline_event_id => event.id,
        :about_with => about_with,
        :wine_detail_id => event.secondary_actor.id)
    end
  end
end
