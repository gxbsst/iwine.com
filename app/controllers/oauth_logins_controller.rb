class OauthLoginsController < ApplicationController
  before_filter :require_no_user

  def new
    @binding_user = User.new
  end


  private
  
  def require_no_user
  	if current_user
  	  notice_stickie t("notice.require_no_user")
  	  redirect_to home_index_path
  	end
  end
  
end
