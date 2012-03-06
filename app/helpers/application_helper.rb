module ApplicationHelper

  def set_layout_class_name
    if params[:action] ==  'show'
       'wineprofile_main'
    elsif params[:action] == 'avatar'
       'user'
    else
      'common_main'
    end
  end

end
