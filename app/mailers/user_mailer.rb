#encoding: utf-8
class UserMailer < ActionMailer::Base
  add_template_helper(ApplicationHelper)
  default from: APP_DATA["email"]["from"]["normal"]

  # email 收件人地址， body邮件内容，user发件人
  def invoting_friends(email, body, user) 
  	#TODO: 将记录放到UserInViteLog    
    subject = "#{user.username}邀请您加入iwine.com"  
    @user = user
    @email = email
    @body = body 
    mail(:to => email, :subject => subject)
  end

  # 发送Welcome Email
  def welcome_alert(user)
  	@user = user
  	mail(:to => @user.email, :subject => APP_DATA["email"]["welcome"]["subject"])
  end

  #被关注发送邮件

  def follow_user(options = {})
    @following_user = options[:following] #被关注的人
    @follower_user = options[:follower] #关注的人
    mail(:to => @following_user.email, :subject => APP_DATA["email"]["follow"]["subject"])  
  end

  def reply_comment(options = {})
    @parent_user = options[:parent_user]
    @reply_user  = options[:reply_user]
    @parent_comment = options[:parent_comment]
    @children = options[:children]
    mail(:to => @parent_user.email, :subject => APP_DATA["email"]["reply"]["subject"])
  end

  def verify_rejected(user)
    @user = user
    mail(:to => user.email, :subject => "您申请的用户认证未通过审核")
  end

  def verify_accepted(user)
    @user = user
    mail(:to => user.email, :subject => "您申请的用户认证已通过审核")
  end
end
