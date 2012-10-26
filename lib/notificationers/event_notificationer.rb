# encoding: utf-8
module Notificationer
  module EventNotificationer

    module InstanceMethods

      # 活动取消
      def send_cancle_event_notification
        subject = "您报名参加的#{self.title}活动取消了"
        body = <<-BODY
        很抱歉地通知您，您报名参加的 #{self.title} 活动被取消了<br />
        <a href="/events/#{self.id}">点击查看活动详情</a><br />
        BODY
        users = self.participants.collect(&:user)
        self.send_system_message(users, body, subject)
        self.participants.each {|participant| EventMailer.event_cancled(participant.email, self, participant).deliver }
      end

      # 活动更新
      def send_update_event_notification
        subject ="您报名参加的#{self.title}活动信息有更新"
        body = <<-BODY
        名字: #{self.title}<br />
        时间: #{self.begin_at.to_s(:cn)}<br/>
        地点: #{self.full_address}<br/>
        <a href="/events/#{self.id}">点击查看活动详情</a><br />
        BODY
        users = self.participants.collect(&:user)
        self.send_system_message(users, body, subject)
        self.participants.each {|participant| EventMailer.event_updated(participant.email, self, participant).deliver }
      end
    end

    # 关于活动参与
    module Participant
      module InstanceMethods

        # 用户参加活动
        def send_join_notification

          subject = "#{self.username}参加了 #{self.event_title} 活动"

          body = <<-BODY_TEXT
            #{self.username}报名参加 #{self.event_title} 活动，<br />
            以下是Ta的详细信息:<br />
            名字:#{self.username} <br />
            电话:#{self.telephone}<br />
            邮箱:#{self.email}<br/>
            留言:#{self.note}<br />
            <a href="/users/#{self.user.slug || self.user.id}/events/#{self.event_id}/participants">点击查看报名情况。</a>
        BODY_TEXT

          event.send_system_message(event_owner, body, subject)
        end

        # 用户取消参加活动
        def send_cancle_notification
          subject = "#{self.username} 退出了 #{self.event_title} 活动"
          body = <<-BODY_TEXT
          #{self.username}退出了#{self.event.begin_at.to_s(:cn)}的?活动，原因是:<br />
          #{self.cancle_note}<br />
          <a href="/users/#{self.user.slug || self.user.id}/events/#{self.event_id}/participants">点击查看报名情况。</a>
          BODY_TEXT
          event.send_system_message(event_owner, body, subject)
        end

        # 用户更新报名信息
        def send_info_changed_notification
          subject = "#{self.username}修改了参加 #{self.event_title} 活动的信息"
          body = <<-BODY
            以下是更新的详细信息<br />
            名字:#{self.username} <br />
            电话:#{self.telephone}<br />
            邮箱:#{self.email}<br/>
            留言:#{self.note}<br />
            <a href="/users/#{self.user.slug || self.user.id}/events/#{self.event_id}/participants">点击查看报名情况。</a>
          BODY
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
