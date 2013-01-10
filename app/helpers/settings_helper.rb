# encoding: utf-8
module SettingsHelper
  def verify_info
    return (link_to "申请认证", new_verify_path) unless current_user.apply_verify?
    html = ""
    if current_user.verified?
      html <<  %Q[认证通过 #{link_to "认证信息", edit_verify_path(current_user.verify)}]
    elsif !current_user.audit?
      html <<  %Q[认证未审核， 请稍后... #{link_to "认证信息", edit_verify_path(current_user.verify)}]
    else
      html <<  %Q[认证未通过审核， 请重新提交. #{link_to "认证信息", edit_verify_path(current_user.verify)}]
    end
    html
  end
end
