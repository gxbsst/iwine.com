# encoding: utf-8
  class MessagesController < ApplicationController

    before_filter :authenticate_user!
    # before_filter :get_mailbox, :get_box, :get_actor
    before_filter :get_mailbox, :get_box
    before_filter :check_users, :only => :create
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
      # @message = Message.new params[:message]
      if @message.conversation_id
        @conversation = Conversation.find(@message.conversation_id)
        unless @conversation.is_participant?(current_user)
          flash[:alert] = "You do not have permission to view that conversation."
          return redirect_to root_path
        end
        receipt = current_user.reply_to_conversation(@conversation, @message.body, nil, true, true, @message.attachment)
        unless receipt.errors.empty?
           notice_stickie("不能回复自己.")
        end
        redirect_to conversation_path(@conversation)
      else
        unless @message.valid?
          return render :new
        end
        # @message.subject = "user_#{current_user.id}_send"
        receipt = current_user.send_message(@recipient_list, @message.body, "subject_#{current_user.id}", true)
        redirect_to conversations_path()
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

    def check_users
      @message = Message.new params[:message]
       @recipient_list = []
       @message.recipients.split(',').each do |s|
         @recipient_list << User.find_by_username(s.strip) unless s.blank?
       end
       @recipient_list
       redirect_to conversations_path, :notice => "找不到用户#{@message.recipients},请重新发送。" if @recipient_list.blank?
     end

end
