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
  def wine_cover_tag(object, options = {})
    unless object.covers.first.nil?
      image_tag object.covers.first.image_url(options[:thumb_name]), options
    else
      theme_image_tag "wine_img.jpg", options
    end
  end

  def wine_waterfall_image_tag(object, options = {})
    unless object.covers.first.nil?
      options[:width] = object.covers.first.width
      options[:height] = object.covers.first.height
      image_tag object.covers.first.image_url(options[:thumb_name]), options
    else
      options[:width] = 200
      options[:height] = 200
      theme_image_tag "wine_img.jpg", options
    end
  end

  ## 显示用户头像
  def user_avatar_tag(object, options = {} )
    if object.avatar.respond_to? "image_url"
      image_tag object.avatar.image_url( options[:thumb_name] ), :width => options[:width], :height => options[:height], :alt => options[:alt]
    else
      theme_image_tag "userpic.jpg", :width => options[:width], :height => options[:height], :alt => options[:alt]
    end
  end

  ## 更改用户登录后跳转的URL
  def after_sign_in_path_for(resource)
    return request.env['omniauth.origin'] || stored_location_for(resource) || home_path
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
  def link_to_user(user_object, url_or_object, link_opts = {}, image_opts = {})
    avatar_version = link_opts[:avatar_version] || :middle
    if link_opts[:with_avatar]
      link_to(image_tag(avatar(user_object, avatar_version), image_opts), url_or_object, link_opts)
    else
      if user_signed_in? # 已登录用户
        if current_user.id == user_object.id
          link_to("我", url_or_object, link_opts)
        else
          link_to(user_object.username, url_or_object, link_opts)
        end
      else # 非登录用户
        link_to(user_object.username, url_or_object, link_opts)
      end
    end
  end

  def avatar(user,version)
    user.avatar.url(version)
  end

  def messages_path(m)
    mine_messages_path(m)
  end

  def special_comments_list(parent)
    parent.special_comments.each do |s|
      "#{s.name} #{s.score} #{s.drinkable_begin.strftime('%Y') if s.drinkable_begin} - #{s.drinkable_end.strftime('%Y') if s.drinkable_end}"
    end
  end


  # 显示评星
  def star_rate_tag(point)
    point ||= 0
    gray_num = 5 - point
    html = ""
    point.times do |i|
      html << (image_tag 'base/star_red.jpg', :width=>15, :height=>14)
    end
    gray_num.times do |i|
      html << (image_tag 'base/star_gray.jpg', :width=>15, :height=>14)
    end
    return html.html_safe
  end

  def link_to_image(path, url, link_opts = { }, image_opts = { })
    link_to theme_image_tag(path, image_opts), url, link_opts
  end

  def previous_page(ids_arr, current_id)
    ids_arr, current_index = page_ids(ids_arr, current_id)
    previous = ids_arr[current_index - 1]
    return current_index != 0 && previous ? previous : false
  end

  def next_page(ids_arr, current_id)
    ids_arr, current_index = page_ids(ids_arr, current_id)
    next_id = ids_arr[current_index + 1]
    return next_id ? next_id : false
  end

  def page_ids(ids_arr, current_id)
    ids_arr = ids_arr.sort
    current_index  = ids_arr.sort.index(current_id)
    return [ids_arr, current_index]
  end

  def reply_comment(comment)
    link_to  reply_comment_path(comment.id),
		  :remote => true,
      :class => "ajax reply_comment_button",
      :id => "reply_#{comment.id}" do
		  raw "回复<span class='reply_comment_count'>(#{comment.children.all.size })</span><span class='reply_result'></span>"
		end
  end
  
  def wine_default_image(version)
    return theme_image_tag("avatar_default_bg_#{version.to_s}.png") if version.present?
    theme_image_tag("avatar_default_bg.png")
  end
  
  def wine_label_tag(wine, options = {})
      unless wine.label.nil?
        options[:thumb_name] = if options.has_key? :thumb_name 
          options[:thumb_name]
        else
          "thumb"
        end
        image_tag wine.label.filename_url(options[:thumb_name]), options
      else
        theme_image_tag "wine_img.jpg", options
      end    
  end
  
  # 主要为了在User Controller 判断是否为当前用户
  def is_login_user?(user)
    if user_signed_in?
      @user == current_user
    else
      false
    end
  end
end
