# encoding: utf-8
module Notificationer

  def send_system_message(recipients, msg_body, subject, sanitize_text=true, attachment=nil)
    convo = Conversation.new({:subject => subject})
    system_message = SystemMessage.new({:sender => self, 
                                       :conversation => convo,  
                                       :body => msg_body, 
                                       :subject => subject, 
                                       :attachment => attachment})

    system_message.recipients = recipients.is_a?(Array) ? recipients : [recipients]
    system_message.recipients = system_message.recipients.uniq
    return system_message.deliver false,sanitize_text
  end

end
