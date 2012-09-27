#encoding: utf-8
class EventMailer < ActionMailer::Base
  add_template_helper(ApplicationHelper)
  default from: APP_DATA["email"]["from"]["normal"]

  # 活动明天举行
  def event_hold_tomorrow(email, event, participant = '')
    subject = "#{event.title}活动明天就要举办了"
    @event = event
    @participant = participant
    mail(:to => email, :subject => subject)
  end

  # 活动取消
  def event_cancled(email, event, participant)
    subject = "您报名参加的#{event.title}活动取消"
    @event = event
    @participant = participant
    mail(:to => email, :subject => subject)
  end

  # 活动信息有更新
  def event_updated(email, event, participant)
    subject = "您报名参加的#{event.title}活动信息有更新"
    @event = event
    @participant = participant
    mail(:to => email, :subject => subject)
  end

end

