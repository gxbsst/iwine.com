# encoding: utf-8
module UsersHelper

  def verify_descirption
    html = ""
    if @user.verified?
      html << %Q[#{ link_to "<span class='user_v'></span>".html_safe, verifies_path } #{@user.verify_desc} <span class="v_apply">#{link_to "申请认证", new_verify_path }</span>]
    else
      html << %Q[<span class="v_apply">#{link_to "申请认证", new_verify_path }</span>]
    end
    html
  end

end
