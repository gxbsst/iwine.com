class TimelineEvent < ActiveRecord::Base
  belongs_to :actor,              :polymorphic => true
  belongs_to :subject,            :polymorphic => true
  belongs_to :secondary_subject,  :polymorphic => true
  belongs_to :secondary_actor,    :polymorphic => true
  
  # belongs_to :timeline, :class_name
  # belongs_to :timeline, 
  #   :class_name => "User::Timeline", 
  #   :foreign_key => "secondary_actor_id", 
  #   : 
  #   :touch => true
  # belongs_to :user, :class_name => "User", :foreign_key => "actor_id"
  
  # Class Methods
  class << self
    def wine_details
      sql = ["SELECT * from 
              (SELECT `timeline_events`.* 
                FROM `timeline_events` 
                WHERE (secondary_actor_type = ? ) 
                ORDER BY created_at DESC  ) 
              as t 
              GROUP BY `secondary_actor_id` ,`event_type` ORDER BY created_at DESC",
              "Wines::Detail"]
      timeline_items = find_by_sql sql
      # preload_associations(timeline_items, :secondary_actor => [:covers, :wine]) ## FOR Rails 2.1
      ActiveRecord::Associations::Preloader.new(timeline_items, :secondary_actor => [:covers, :wine]).run
      return timeline_items
    end

    def wineries
      sql = ["SELECT * from 
              (SELECT `timeline_events`.* 
                FROM `timeline_events` 
                WHERE (secondary_actor_type = ? ) 
                ORDER BY created_at DESC  ) 
              as t 
              GROUP BY `secondary_actor_id` ,`event_type` ORDER BY created_at DESC",
              "Winery"]
      timeline_items = find_by_sql sql
      ActiveRecord::Associations::Preloader.new(timeline_items, :secondary_actor => [:covers]).run
      return timeline_items

      # where(["secondary_actor_type = ?","Winery"]).
      #   includes(:actor, {:secondary_actor => [:covers]} ).order("created_at DESC").
      #   group([:secondary_actor_id, :event_type])
    end
  end
end
