class UserMailer < ActionMailer::Base
  default from: APP_DATA["email"]["from"]["normal"]

  # email 收件人地址， body邮件内容，user发件人
  def invoting_friends(email, body, user)
  	#TODO: 将记录放到UserInViteLog
    @user = user
    @email = email
    @body = body
    mail(:to => email, :subject => body)
  end

  # 发送Welcome Email
  def welcome_alert(user)
  	@user = user
  	mail(:to => @user.email, :subject => APP_DATA["email"]["welcome"]["subject"])
  end
end
