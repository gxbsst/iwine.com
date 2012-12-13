#encoding: utf-8
class FriendMailer < ActionMailer::Base
  add_template_helper(ApplicationHelper)
  default from: APP_DATA["email"]["from"]["normal"]

  def invite(params)
    mail(:to => params[:email], :subject => params[:subject]) { |format| format.text { render :text => params[:body] }}
  end

end
