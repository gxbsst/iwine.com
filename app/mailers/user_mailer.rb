class UserMailer < ActionMailer::Base
  default from: "mail.sidways.com"

  #email 收件人地址， body邮件内容，user发件人
  def invoting_friends(email, body, user)
  	#TODO: 将记录放到UserInViteLog
    @user = user
    @email = email
    @body = body
    mail(:to => email, :subject => body)
  end
end
