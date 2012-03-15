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

  def stylesheet_if_exists(*stylesheets)
    results = []
    stylesheets.each do |file_name|
      results << stylesheet_link_tag(file_name) if File.exist?(Rails.root.join('app', 'assets', 'stylesheets',"#{file_name}.css"))
    end

    return results.join("\n")
  end
  
  def title(page_title, options={})
    content_for(:title, page_title.to_s)
    return content_tag(:h2, page_title, options)
  end
  
  ## 显示酒的封面
  def wine_cover_tag(object, options = {} )
    if object.cover.respond_to? "image_url"
      image_tag object.cover.image_url( options[:thumb_name] ), :width => options[:width], :height => options[:height], :alt => options[:alt]
    else
      image_tag "base/test/win_50p.jpg"
    end
  end

  ## 显示用户头像
  def user_avatar_tag(object, options = {} )
    if object.avatar.respond_to? "image_url"
      image_tag object.avatar.image_url( options[:thumb_name] ), :width => options[:width], :height => options[:height], :alt => options[:alt]
    else
      image_tag "base/test/user_img50.jpg", :width => options[:width], :height => options[:height], :alt => options[:alt]
    end  
  end
  
  ## 更改用户登录后跳转的URL
  def after_sign_in_path_for(resource)
    return request.env['omniauth.origin'] || stored_location_for(resource) || mine_path
  end
  
end
