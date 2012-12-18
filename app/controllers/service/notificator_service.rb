# encoding: utf-8
module Service
  class NotificatorService

    #Usage:
    #    sender = User.find(2)
    #    receiver = User.find(3) || User.find([3,4])
    #    content = "here is content"
    #    options = {:subject => "here is subject"}
    #    block = lambda {|receipt| do something }
    #    Service::NotificatorService.message(sender, receiver, content, options) &block

    def self.message(sender, receiver, content, options = {}, &block)
      new(sender, receiver, content, options, &block).execute
    end

    #Usage:
    #    sender = Event.find(2)
    #    receiver = User.find(3) || User.find([3,4])
    #    content = "here is content"
    #    options = {:subject => "here is subject"}
    #    block = lambda {|receipt| do something }
    #    Service::NotificatorService.notification(sender, receiver, content, options) &block
    def self.notification(sender, receiver, content, options = {}, &block)
      new(sender, receiver, content, options, &block).send_system_message
    end

    def initialize(sender, receiver, content, options, &block)
      @sender = sender
      @receiver = receiver.is_a?(Array) ? receiver : [receiver]
      @content = content
      @options = options
      @block = block
    end

    def execute
      send_message
    end

    def send_system_message
      options = {:sanitize_text => true, :attachment => nil}
      convo = Conversation.new({:subject => subject})
      system_message = SystemMessage.new({:sender => @sender,
                                          :conversation => convo,
                                          :body => @content,
                                          :subject => subject,
                                          :attachment => options[:attachment]})

      system_message.recipients = @receiver
      system_message.recipients = system_message.recipients.uniq
      @block.call(@receiver) if @block
      system_message.deliver false, options[:sanitize_text]
    end

    def has_conversation?(sender, receiver)
      #Conversation
      #c =  Conversation.scoped(:joins => [:messages, :receipts],
      #                     :conditions => "notifications.sender_id = 2 AND receipts.receiver_id =3")
      joins = "LEFT OUTER JOIN `notifications` ON conversations.id = notifications.conversation_id
              LEFT OUTER JOIN `receipts` ON notifications.id = receipts.notification_id"

      condition = "notifications.sender_id = #{sender.id} AND receipts.receiver_id = #{receiver.id}"
      result = Conversation.scoped(:joins => joins, :conditions => condition ).uniq
      result.present? ? result.first : false
    end

    private

    def send_message
      @receiver.each do |receiver|
        conversation = has_conversation?(@sender, receiver)
        receipt = receipt(conversation, receiver)
        @block.call(receipt) if @block
      end
    end

    def receipt(conversation, receiver)
      conversation ? reply_message(@sender, conversation) : new_message(receiver)
    end

    def reply_message(sender, conversation)
      sender.reply_to_conversation(conversation, @content, nil, true, true, @options[:attachment])
    end

    def new_message(receiver)
      @sender.send_message(receiver, @content, subject, true)
    end

    def subject
      @options[:subject] || Time.now.to_s
    end

  end

end