class EventInvitee < ActiveRecord::Base
  belongs_to :user
  belongs_to :event
  attr_accessible :comfirm_status, :invite_log
end
