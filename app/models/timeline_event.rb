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
end
