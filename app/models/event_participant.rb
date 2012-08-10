class EventParticipant < ActiveRecord::Base
  belongs_to :user
  belongs_to :event
  attr_accessible :cancle_note, :email, :join_status, :note, :telephone, :username
end
