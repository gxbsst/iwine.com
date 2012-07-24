module Users::Helpers::ConfigHelperMethods
  module ClassMethods
    
  end

  module InstanceMethods

   # 分享:加入酒窖
   def share_when_add_wine_to_cellar?
     return profile.config.share.wine_cellar == USER_CONFIG_NORMAL # "1"
   end
   
   # 分享: 评论某支酒
   def share_when_do_wine_detail_comment?
     return profile.config.share.wine_detail_comment == USER_CONFIG_NORMAL # "1"
   end
   
   # 接收来自所有人的私信
   def receive_message_from_all?
     return profile.config.notice.message == USER_CONFIG_MESSAGE_FROM_ALL # "1"
   end
   
   # 接收来自我关注的人的私信
   def receive_message_from_my_following?
     return profile.config.notice.message == USER_CONFIG_MESSAGE_FROM_MY_FOLLOWING # "3"
   end
   
   # Email: 当被私信
   def receive_email_when_messaged?
     config = USER_CONFIG_RECIEVE_MESSAGE_EMAIL # "1"
     profile.config.notice.email.include? config
   end
   
   # Email: 当评论被回复
   def receive_email_when_comment_replied?
     config = USER_CONFIG_RECIEVE_REPLY_EMAIL # "2"
     profile.config.notice.email.include? config
   end

   # Email: 被关注
   def receive_email_when_followed?
    config = USER_CONFIG_FOLLOWED_EMAIL # "3"
    profile.config.notice.email.include? config
   end
   
   # Email: 接收最新产品信息
   def receive_product_info_email?
    config = USER_CONFIG_RECIEVE_REPLY_EMAIL # "4"
    profile.config.notice.email.include? config
   end

   # Email: 接收帐户信息
   def receive_acount_info_email?
     config = USER_CONFIG_RECIEVE_ACCOUNT_INFO_EMAIL # "5"
     profile.config.notice.email.include? config
   end

  end

  def self.included(receiver)
    receiver.extend         ClassMethods
    receiver.send :include, InstanceMethods
  end
end
