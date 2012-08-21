class EventInvitee < ActiveRecord::Base
  belongs_to :invitee,  :class_name => 'User', :foreign_key => 'invitee_id' # 被邀请者
  belongs_to :inviter,  :class_name => 'User', :foreign_key => 'inviter_id' # 邀请者
  belongs_to :event
  belongs_to :invitable, :polymorphic => true
  attr_accessible :confirm_status, :invite_log, :invitee_id, :inviter_id

  class << self

    # 检查被邀请的用户已经存在
    def check_exist?(invitable_type, invitable_id, invitee_id)
      where(:invitable_type => invitable_type,
            :invitable_id => invitable_id,
            :invitee_id => invitee_id)
    end

    def get_one_invitee(user_id, event_id)
     find_by_user_id_and_event_id(user_id, event_id)
    end

  end
end
