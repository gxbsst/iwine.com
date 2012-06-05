# encoding: utf-8
  class MessagesController < ApplicationController

    before_filter :authenticate_user!
    # before_filter :get_mailbox, :get_box, :get_actor
    before_filter :get_mailbox, :get_box
    before_filter :build_message, :only => :create
    before_filter :check_can_send?, :only => :create
    # before_filter :get_box

    def index
      redirect_to conversations_path(:box => @box)
       @box = params[:box] || 'inbox'
        @messages = current_user.mailbox.inbox if @box == 'inbox'
        @messages = current_user.mailbox.sentbox if @box == 'sent'
        @messages = current_user.mailbox.trash if @box == 'trash'
    end

    # GET /messages/1
    # GET /messages/1.xml
    def show
      if @message = Message.find_by_id(params[:id]) and @conversation = @message.conversation
        if @conversation.is_participant?(@actor)
          redirect_to conversation_path(@conversation, :box => @box, :anchor => "message_" + @message.id.to_s)
          return
        end
      end
      redirect_to conversations_path(:box => @box)
    end

    # GET /messages/new
    # GET /messages/new.xml
    def new
      # if params[:receiver].present?
      #   @recipient = Actor.find_by_slug(params[:receiver])
      #   return if @recipient.nil?
      #   @recipient = nil if Actor.normalize(@recipient)==Actor.normalize(current_subject)
      # end
      @message = Message.new
    end

    # GET /messages/1/edit
    def edit

    end

    # POST /messages
    # POST /messages.xml
    def create

      if @message.conversation_id # 回复
        @conversation = Conversation.find(@message.conversation_id)
        unless @conversation.is_participant?(current_user)
          notice_stickie("你不能回复这个私信。")
          return redirect_to root_path
        end
        receipt = current_user.reply_to_conversation(@conversation, @message.body, nil, true, true, @message.attachment)
        unless receipt.errors.empty?
           notice_stickie("不能回复自己.")
        end
        redirect_to conversation_path(@conversation)
      else # 新的私信
        unless @message.valid?
          return render :new
        end
        @recipient_list = []
        @message.recipients.split(',').each do |s|
          @recipient_list << User.find_by_username(s.strip) unless s.blank?
        end
                
        receipt = current_user.send_message(@recipient_list, @message.body, "subject_#{current_user.id}", true)
        redirect_to conversations_path
      end
      # flash[:notice] = "Message sent."
      # redirect_to mine_conversation_path(@conversation)
      # @recipients = Array.new
      # if params[:_recipients].present?
      #   params[:_recipients].each do |recp_id|
      #     recp = Actor.find_by_id(recp_id)
      #     next if recp.nil?
      #     @recipients << recp
      #   end
      # end
      # @receipt = @actor.send_message(@recipients, params[:body], params[:subject])
      # if (@receipt.errors.blank?)
      #   @conversation = @receipt.conversation
      #   flash[:success]= t('mailboxer.sent')
      #   redirect_to conversation_path(@conversation, :box => :sentbox)
      # else
      #   render :action => :new
      # end
    end

    # PUT /messages/1
    # PUT /messages/1.xml
    def update

    end

    # DELETE /messages/1
    # DELETE /messages/1.xml
    def destroy

    end

    def trash
      conversation = Conversation.find_by_id(params[:id])
      if conversation
        current_user.trash(conversation)
        flash[:notice] = "Message sent to trash."
      else
        conversations = Conversation.find(params[:conversations])
        conversations.each { |c| current_user.trash(c) }
        flash[:notice] = "Messages sent to trash."
      end
      redirect_to messages_path(box: params[:current_box])
    end

    def untrash
      conversation = Conversation.find(params[:id])
      current_user.untrash(conversation)
      flash[:notice] = "Message untrashed."
      redirect_to messages_path(box: 'inbox')
    end

    private

    def get_mailbox
      @mailbox = current_user.mailbox
    end

    def get_actor
      @actor = Actor.normalize(current_subject)
    end

    def get_box
      if params[:box].blank? or !["inbox","sentbox","trash"].include?params[:box]
        @box = "inbox"
        return
      end
      @box = params[:box]
    end

    #如果用户设置通知设置（检测只有关注用户才可以发私信)

    def build_message
      @message = Message.new params[:message]
    end
    def check_can_send?
      unless @message.conversation_id
        user = User.where("username = ?", params[:message][:recipients]).first
        if user
          if user.profile.config.notice.message.to_i == 3 && !user.following_ids.include?(current_user.id)
            notice_stickie("只有关注 <strong>#{params[:message][:recipients]}</trong> 后才能给TA发送私信。")
            redirect_to conversations_path
          end
        else
          notice_stickie("没有找到用户 <strong>#{params[:message][:recipients]}</trong>，请检查用户名是否填写正确。")
          redirect_to conversations_path
        end
      end
    end

end
