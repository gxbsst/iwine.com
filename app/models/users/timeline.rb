class Users::Timeline < ActiveRecord::Base
  include Users::UserSupport
  belongs_to :timeline_event
  
  # 关于关注酒的行为
  # 关注的酒被评论的列表
  # has_many :comments, 
  #   :class_name => "TimelineEvent", 
  #   :foreign_key => "secondary_actor_type_id",
  #   :conditions => "event_type = 'new_comment'"
  # # 关注的酒的被关注列表
  # has_many :follower, 
  #     :class_name => "TimelineEvent", 
  #     :foreign_key => "secondary_actor_type_id",
  #     :conditions => "event_type = 'new_follow'"
  # # 关注的酒的活动列表      
  # has_many :events, 
  #     :class_name => "TimelineEvent", 
  #     :foreign_key => "secondary_actor_type_id",
  #     :conditions => "event_type = 'new_follow'"
  # # 关注的酒的图片列表
  # has_many :photos, 
  #     :class_name => "TimelineEvent", 
  #     :foreign_key => "secondary_actor_type_id",
  #     :conditions => "event_type = 'new_photo'"      
end
