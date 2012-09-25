# encoding: utf-8
module Notificationer
  module EventNotificationer

    module InstanceMethods
      def send_canle_event_notification
        subject = '活动取消了'
        body = "您参加的活动 [#{self.title}] 取消了"
        users = self.participants.collect(&:user)
        self.send_system_message(users, body, subject)
      end
    end

    # 关于活动参与
    module Participant
      module InstanceMethods
        # 用户参加活动
        def send_join_notification
          subject = "#{self.user_username}参加了你的活动"

          body = <<-BODY_TEXT
        "#{self.user_username}用户在#{self.created_at.to_s(:normal)}报名参加的您组织的
          #{self.event_title} 活动.
        BODY_TEXT

          event.send_system_message(event_owner, body, subject)
        end

        # 用户取消参加活动
        def send_cancle_notification
          subject = "#{self.user_username}取消参加了你的活动"

          body = <<-BODY_TEXT
        "#{self.user_username}用户在#{self.created_at.to_s(:normal)}报名参加的您组织的
          #{self.event_title} 活动，很遗憾因为 #{self.cancle_note} Ta不能来参加这次的活动了"
        BODY_TEXT
          event.send_system_message(event_owner, body, subject)
        end
      end

      def self.included(receiver)
        receiver.send :include,  Module.nesting.last
        receiver.send :include, InstanceMethods
      end
    end

    # 关于活动邀请
    module Invitee
      module InstanceMethods

      end

      def self.included(receiver)
        receiver.send :include,  Module.nesting.last
        receiver.send :include, InstanceMethods
      end
    end

    def self.included(receiver)
      receiver.send :include,  Module.nesting.last
      receiver.send :include, InstanceMethods
    end

  end
end
