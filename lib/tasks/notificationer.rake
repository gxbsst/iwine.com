#encoding: UTF-8
namespace :notificationer do
  namespace :event do

    desc "给明天参加活动的用户发送通知"
    task :hold_tomorow  => :environment do
      events = ::Event.live.date_with(Time.now.tomorrow.to_date)

      unless events.blank?
        events.each do |event|
          subject = "#{event.title}活动明天就要举办了"

          body = <<-BODY
              您报名参加的 #{event.title} 活动明天就要举办了，请准时参加。<br />
              名字: #{event.title}<br />
              时间: #{event.begin_at.to_s(:cn)}<br />
              地点: #{event.address}<br />
              <a href="/event/#{event.id}">点击查看详情</a>
          BODY
          @event = event
          users = event.participants.map(&:user)

          unless users.blank?
            # 发送通知
            event.send_system_message(users, body, subject)
            # 发送Email
            users.each {|user| EventMailer.event_hold_tomorrow(user.email, @event).deliver }
          end

        end
      end

    end
  end
end
