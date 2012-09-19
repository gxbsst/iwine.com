class SystemMessagesController < ApplicationController
	before_filter :authenticate_user!

	def index
		params[:page] ||= 1
		#获取此人未trash的所有通知
		@receipts = current_user.receipts.
			                       joins(:notification).
			                       where('notifications.type' => SystemMessage.to_s).
			                       page(params[:page]).per(10)

	end
end
