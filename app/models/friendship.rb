# Attributes:
# * id [integer, primary, not null, limit=4] - primary key
# * created_at [datetime, not null] - creation time
# * follower_id [integer, limit=4] - belongs to User
# * updated_at [datetime, not null] - last update time
# * user_id [integer, limit=4] - belongs to User
class Friendship < ActiveRecord::Base
  belongs_to :follower, :class_name => 'User', :foreign_key => 'follower_id'
  belongs_to :user

end
