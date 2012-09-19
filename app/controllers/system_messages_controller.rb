class SystemMessagesController < ApplicationController
	before_filter :authenticate_user!
	before_filter :mark_read, :only => :show # 必须在 get_unread_receipt_count 前面
	before_filter :check_is_trashed, :only => :show
  before_filter :get_unread_count, :only => [:show, :index]
	def index
		params[:page] ||= 1
		#获取此人未trash的所有通知
		@receipts = current_user.receipts.
														not_trash.
														joins(:notification).
			                      where('notifications.type' => SystemMessage.to_s).
			                      page(params[:page]).per(10)

	end

	def show
	end

	def move_to_trash
		receipts = find_receipts
		receipts.each do |receipt|
			receipt.move_to_trash
		end

		redirect_to system_messages_path
	end

	def mark_as_read
		receipts = find_receipts
		receipts.each do |receipt|
			receipt.mark_as_read
		end

		redirect_to system_messages_path
	end

	private

	def find_receipts
		current_user.receipts.find(params[:receipt_id])
	end

	def mark_read
		@receipt = current_user.receipts.find(params[:id])
		@receipt.mark_as_read if @receipt.is_unread?
	end

	def check_is_trashed
		if @receipt.is_trashed?
			notice_stickie t("notice.system_message.no_access")
			redirect_to system_messages_path
		end
	end

end
