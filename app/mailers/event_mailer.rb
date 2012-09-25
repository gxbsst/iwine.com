#encoding: utf-8
class EventMailer < ActionMailer::Base
  add_template_helper(ApplicationHelper)
  default from: APP_DATA["email"]["from"]["normal"]

  def event_hold_tomorrow(email, event, participant = '')
    subject = "#{event.title}活动明天就要举办了"
    @event = event
    @participant = participant
    mail(:to => email, :subject => subject)
  end

end

