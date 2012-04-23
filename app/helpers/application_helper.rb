# -*- coding: utf-8 -*-
module ApplicationHelper

  def set_layout_class_name

    if params[:action] ==  'show' && params[:controller] == "wines"
      'wineprofile_main'
    elsif params[:action] == 'avatar'
      'user'
    elsif params[:controller] == "static" || params[:controller] == "wines"
      "span_950"
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
    # return content_tag(:h2, page_title, options)
    html = <<-HTML
      <div id="main_t" class="clearfix">
      <h1>#{page_title}</h1>
      <div class="clear"></div>
     </div>
    HTML
    return html.html_safe
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

  def link_to_icon(icon_name, url_or_object, options={})
    options.merge!({ :class => "icon #{icon_name}" })

    link_to(image_tag("v2/icon/#{icon_name}.png", { :title => icon_name, :align => "center" }),
            url_or_object,
            options)
  end

  def link_to_sns_icon(available, sns_name, url_or_object, options={})
    options.merge!({ :class => "icon #{sns_name}" })

    if available
      icon_name = 'icon_' + sns_name + '_on'
    else
      icon_name = 'icon_' + sns_name + '_off'
    end


    link_to(image_tag("v2/icon/#{icon_name}.png", { :title => icon_name }),
            url_or_object,
            options)
  end

  def link_to_button(button_name, url_or_object, options={})
    options.merge!({ :class => "button #{button_name}" })

    link_to(image_tag("v2/button/#{button_name}.png", { :title => button_name, :align => "center" }),
            url_or_object,
            options)
  end

  def link_to_sync_button(sns_name, url_or_object, options={})
    options.merge!({ :class => "button #{sns_name}" })

    button_name = 'btn_syn_' + sns_name
    link_to(image_tag("v2/button/#{button_name}.jpg", { :title => button_name }),
            url_or_object,
            options)
  end

  ## Link to User with avatar
  def link_to_user(user_object, url_or_object, options={})
    avatar_version = options[:avatar_version] || :middle
    if options[:with_avatar]
      link_to(image_tag(avatar(user_object,avatar_version), :align => "left"), url_or_object, options)
    else
      if current_user.id == user_object.id
        link_to("我", url_or_object, options)
      else
        link_to(user_object.username, url_or_object, options)
      end
    end
  end

  def avatar(user,version)
    user.avatar.url(version)
  end

  def messages_path(m)
    mine_messages_path(m)
  end
end
