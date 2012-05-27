class UserMailer < ActionMailer::Base
  default from: "mail.sidways.com"

  #email 收件人地址， body邮件内容，user发件人
  def invoting_friends(email, body, user)
    @user = user
    mail(:to => email, :subject => body)
  end
end
