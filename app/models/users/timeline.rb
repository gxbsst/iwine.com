# -*- coding: utf-8 -*-
class Users::Timeline < ActiveRecord::Base
  include Users::UserSupport
  belongs_to :timeline_event
  belongs_to :ownerable, :polymorphic => true
  belongs_to :receiverable, :polymorphic => true

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

  # 判断用户关注的酒或者酒庄已经存在, 如果存在就更新updated_at
  def self.receiver_item(user_id, event_type, receiver, receiver_id)
    where(["user_id = ? && event_type = ? && receiverable_type = ? && receiverable_id = ?",
            user_id, event_type, receiver, receiver_id])
  end

end
