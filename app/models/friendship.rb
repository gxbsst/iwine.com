# Attributes:
# * id [integer, primary, not null, limit=4] - primary key
# * created_at [datetime, not null] - creation time
# * follower_id [integer, limit=4] - belongs to User
# * updated_at [datetime, not null] - last update time
# * user_id [integer, limit=4] - belongs to User
class Friendship < ActiveRecord::Base

  belongs_to :follower, :class_name => 'User', :foreign_key => 'follower_id'
  belongs_to :user
  after_create :mail_notification, :if => :mail_notification?

  def mail_notification
      UserMailer.follow_user(
        :following => user, 
        :follower => follower).deliver 
  end

  private

  def mail_notification?
    user.receive_email_when_followed?
  end

end
