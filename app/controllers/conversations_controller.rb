# encoding: utf-8
class ConversationsController < ApplicationController
  before_filter :authenticate_user!
  # before_filter :get_mailbox, :get_box, :get_actor
  before_filter :get_mailbox, :get_box
  before_filter :check_current_subject_in_conversation, :only => [:show, :update, :destroy,:reply]
  def index
    # binding.pry 
    @message = Message.new
    @conversations = @mailbox.conversations.order("created_at DESC").page(params[:page]).per(9)
    
    # mask all items as read
    @unreads = Conversation.unread(current_user)
    unless @unreads.blank?
      @unreads.each do |i|
        i.mark_as_read(current_user)
      end
    end
    # if @box.eql? "inbox"
    #   @conversations = @mailbox.inbox.page(params[:page]).per(9)
    # elsif @box.eql? "sentbox"
    #   @conversations = @mailbox.sentbox.page(params[:page]).per(9)
    # else
    #   @conversations = @mailbox.trash.page(params[:page]).per(9)
    # end
  end

  def show
    @conversation = Conversation.find_by_id(params[:id])
    unless @conversation.is_participant?(current_user)
      notice_stickie t("notice.no_ability")
      return redirect_to root_path
    end
    @message = Message.new conversation_id: @conversation.id
    current_user.read(@conversation)
    #
    #
    # if @box.eql? 'trash'
    #   @receipts = @mailbox.receipts_for(@conversation).trash
    # else
    #   @receipts = @mailbox.receipts_for(@conversation).not_trash
    # end
    # render :action => :show
    # @receipts.mark_as_read
  end

  def new

  end

  def edit

  end

  def create

  end

  def update
    if params[:untrash].present?
      @conversation.untrash(@actor)
    end

    if params[:reply_all].present?
      last_receipt = @mailbox.receipts_for(@conversation).last
      @receipt = @actor.reply_to_all(last_receipt, params[:body])
    end

    if @box.eql? 'trash'
      @receipts = @mailbox.receipts_for(@conversation).trash
    else
      @receipts = @mailbox.receipts_for(@conversation).not_trash
    end
    redirect_to :action => :show
    @receipts.mark_as_read

  end

  def destroy

    @conversation.move_to_trash(@actor)

    respond_to do |format|
      format.html {
        if params[:location].present? and params[:location] == 'conversation'
          redirect_to conversations_path(:box => :trash)
        else
          redirect_to conversations_path(:box => @box,:page => params[:page])
        end
      }
      format.js {
        if params[:location].present? and params[:location] == 'conversation'
          render :js => "window.location = '#{conversations_path(:box => @box,:page => params[:page])}';"
        else
          render 'conversations/destroy'
        end
      }
    end
  end

  def search
    @message = Message.new
    if user = User.find_by_username(params[:search])
      conditions = ["receipts.receiver_id=? AND (notifications.body like ? OR notifications.sender_id=?)", current_user.id, "%" + params[:search] + "%", user.id]
    else
      conditions = ["receipts.receiver_id=? AND (notifications.body like ?)", current_user.id, "%" + params[:search] + "%"]
    end
    @receipts = Receipt.all(:joins => "LEFT OUTER JOIN `notifications` ON notifications.id = receipts.notification_id",
      :include => [:notification => :conversation],
    :conditions => conditions)
    if !@receipts.blank?
      @conversations = @receipts.inject([]) do |memo, receipt|
        memo << receipt.notification.conversation
      end
      #TODO: 加分页
      # page = params[:page] || 1
      # if !(@conversations.nil?)
      #   unless @conversations.kind_of?(Array)
      #     @conversations = @conversations.page(page).per(8)
      #   else
      #     @conversations = Kaminari.paginate_array(@conversations).page(page).per(10)
      #   end
      # end
    end

  end

  private

  def get_mailbox
    @mailbox = current_user.mailbox
  end

  # def get_actor
  #   @actor = Actor.normalize(current_subject)
  # end

  def get_box
    if params[:box].blank? or !["inbox","sentbox","trash"].include?params[:box]
      @box = "inbox"
      return
    end
    @box = params[:box]
  end

  def check_current_subject_in_conversation
    @conversation = Conversation.find_by_id(params[:id])

    if @conversation.nil? or !@conversation.is_participant?(current_user)
      # if @conversation.nil?
      redirect_to conversations_path(:box => @box)
      return
    end
  end

end
