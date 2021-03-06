# -*- coding: utf-8 -*-
module ApplicationHelper

  def truncate_u(text, length = 30, truncate_string = "...")
    l=0
    char_array=text.unpack("U*")
    char_array.each_with_index do |c,i|
      l = l+ (c<127 ? 0.5 : 1)
      if l>=length
        return char_array[0..i].pack("U*")+(i<char_array.length-1 ? truncate_string : "")
      end
    end
    return text
  end 

  def photo_photo_comments_path(commentable,comment)
    return "/photos/#{commentable.id}/comments"
  end

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
    content_for(:title) { page_title }
  end

  def wine_name_zh_link(name, wine_detail, options = {})
    if name.present?
      link_to(name, wine_path(wine_detail), options)
    end
  end

  ## 显示酒的封面
  def wine_cover_tag(object, options = {})
    cover = get_cover object
    if cover
      image_tag cover.image_url(options[:thumb_name]), options
    else
      image_tag "common/wine_#{options[:thumb_name]}.png", options
    end
  end

  def wine_label_tag(object, options = {})
    label = get_label(object)
    if label
      image_tag label.image_url(options[:thumb_name]), options
    else
      image_tag "common/wine_#{options[:thumb_name]}.png", options
    end
  end

  def winery_cover_tag(winery, options = {})
    cover = get_cover(winery)
    if cover
      image_tag cover.image_url(options[:thumb_name]), options
    else
      image_tag "common/winery_#{options[:thumb_name]}.png", options
    end
  end

  def winery_label_tag(winery, options ={})
    label = get_label winery
    if label
      image_tag label.image_url(options[:thumb_name]), options
    else
      image_tag "common/winery_#{options[:thumb_name]}.png", options
    end
  end

  def wine_waterfall_image_tag(object, options = {})
    cover =  get_cover object
    if cover
      options[:thumb_name] = :middle_x unless options.has_key? :thumb_name
      options[:width] = cover.width
      options[:height] = cover.height
      image_tag cover.image_url(options[:thumb_name]), options
    else
      options[:width] = 200
      options[:height] = 200
      image_tag "common/wine_#{options[:thumb_name]}.png", options
    end
  end

  def get_cover(object)
    cover = object.photos.cover.approved.first
    if object.class.name == "Wines::Detail" && cover.nil?
      cover = object.wine.photos.cover.approved.first
    end
    return cover
  end

  def get_label(object)
    label = object.photos.label.approved.first
    if object.class.name == 'Wines::Detail' && label.nil?
      label = object.wine.photos.label.approved.first
    end
    return label
  end
  ## 显示用户头像
  def user_avatar_tag(object, options = {} )
    image_tag avatar(object, options[:thumb_name] ), :width => options[:width], :height => options[:height], :alt => options[:alt]
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


    link_to(image_tag("v2/icon/#{icon_name}.png", { :title => icon_name, :align => "absmiddle" }),
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

    button_name = 'btn_syn_' + sns_name
    link_to(image_tag("common/#{button_name}.jpg", { :title => button_name }),
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

  # def messages_path(m)
  #   mine_messages_path(m)
  # end


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
    link_to image_tag(path, image_opts), url, link_opts
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

  def photo_number(ids_arr, current_id)
    ids_arr, current_index = page_ids(ids_arr, current_id)
    return "#{current_index.to_i + 1} / #{ids_arr.count}"
  end

  def page_ids(ids_arr, current_id)
    ids_arr = ids_arr.sort
    current_index  = ids_arr.sort.index(current_id)
    return [ids_arr, current_index]
  end

  def comment_detail_url(comment)
    url = case comment.commentable_type
          when "Photo"
            photo_comment_path(comment.commentable, comment)
          when "Wines::Detail", "Wine"
            wine_comment_path(comment.commentable, comment)
          when "Winery"
            winery_comment_path(comment.commentable, comment)
          when "Event"
            event_comment_path(comment.commentable, comment)
          end
    link_to url do
      raw "回复<span class='reply_comment_count'>(#{comment.children.all.size })</span><span class='reply_result'></span>"
    end
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
    return image_tag("avatar_default_bg_#{version.to_s}.png") if version.present?
    image_tag("avatar_default_bg.png")
  end


  # 主要为了在User Controller 判断是否为当前用户
  def is_login_user?(user)
    if user_signed_in?
      user == current_user
    else
      false
    end
  end

  def show_username(user)
    is_login_user?(user) ? "我" : user.username
  end

  def conversation_url(user)
    if is_login_user?(user)
      link_to "私信", conversations_path, :class => "icon_mail"
    else
      link_to "私信", new_message_path(:receiver => user.username), :remote => true, :class => "icon_mail ajax"
    end
  end

  #  下拉菜单: 获取热门酒
  def get_hot_wine(limit)
    Wines::Detail.hot_wines(1)
  end

  #  下拉菜单: 获取热门酒
  def get_hot_wineries(limit)
    Winery.hot_wineries(1)
  end

  #for sns_share

  def sns_url(object)
    sns_url = case object.class.name
    when 'Winery'
      winery_url(object)
    when 'Wines::Detail'
      wine_url(object)
    when "Note"
      note_url(object.app_note_id)
    end
    sns_url
  end

  def sns_title(object)
    title = case object.class.name
    when 'Winery'
      object.name
    when 'Wines::Detail'
      object.origin_zh_name
    when 'User'
      object.username
    when 'Event'
      object.title
    end
    "【#{title}】"
  end

  def sns_summary(object, type = false)
    model_type = type ? type : object
    desc = case model_type
    when 'Winery'
      object.info_items.first.description if object.info_items.first
    when 'Wines::Detail'
      object.description
    when 'Event'
      object.title
    when "Note"
      object
    end
    truncate(desc.to_s.strip.gsub(/\r|\n/, ''), :length => 70)
  end

      #分享到sns
  def note_sns_summary(vintage, name, star, comment)
    %Q[#{vintage} #{name} #{star}星 #{sns_summary(comment, 'Note')}]
  end

  def sns_image_url(object, options = {})
    case object.class.name
    when "Photo"
      cover = object
    when  "Event"
      photo = object.poster_url(options[:thumb_name]) if object.poster.present?
    else
      cover = get_cover(object)
    end
    if cover
      "#{root_url}#{cover.image_url(options[:thumb_name])}"
    elsif photo
      "#{root_url}#{photo}"
    end
  end

  def drinkable(object)
    date_begin = object.drinkable_begin
    date_end = object.drinkable_end
    if date_begin || date_end
      "#{date_begin.to_s(:year) if date_begin} - #{date_end.to_s(:year) if date_end}"
    end
  end

  #展示所有的 variety_percentage
  def variety_percentage_lists(detail, variety = nil)
    show_list = ''
    if variety.present?
      variety_arr = variety.gsub(";", ":").split(":")
      variety_hash = Hash[*variety_arr]
      variety_hash.each do |key, value|
        name = Wines::VarietyPercentage.where(:id => key).first.try(:name_en)
        percentage = value.to_i == 0 ? nil : "#{value}%"
        show_list << %Q[#{name}(#{percentage})]
      end
      show_list.gsub(/、$/, '')
    elsif detail
      count = detail.variety_percentages.length
      detail.variety_percentages.each_with_index do |v, index|
        show_list << "#{v.origin_name} (#{v.show_percentage})#{' 、' if index + 1 != count}"
      end
      show_list
    end
  end

  def yield_for(content_sym, default)
    output = content_for(content_sym)
    if output.blank?
      output = default
    else
      output += "-#{APP_DATA['site']}"
    end
    output
  end

  def link_to_outside_website(website, options = {})
    if website.present?
      final_url = website.include?("http://") ? website : "http://#{website}"
      link_to website, final_url, options
    end
  end

  def show_bio(bio, myself = true)
    bio.present? ? bio : (myself ? APP_DATA["user_profile"]["myself_no_bio"] : APP_DATA["user_profile"]["no_bio"])
  end

  def album_cover_tag(user, album)
    cover = album.photos.visible.cover.first
    if album.is_public.to_i == 0 && !is_login_user?(user)
      tag = image_tag("common/p_album.png")
    else
      if cover
        tag =  image_tag(cover.image_url(:x_middle))
      else
        tag = image_tag( "album.jpg")
      end
    end
    if album.is_public.to_i == 0 && !is_login_user?(user) #非公开
      tag
    else
      link_to tag, album_show_user_path(user, album), :class => :cover
    end
  end

  def show_clear_div(index)
    value = index/4.0
    if index != 0 && value != 0 && value.to_i == value
      "<div class='clear'></div>"
    end
  end

  def item_non_public(is_public)
    if is_public.to_i == 1
      %Q[<span class="non_public"> \
      #{image_tag("icon/non_public.png", 
      :width => "16",
      :height => "16",
      :alt => "仅自己可见", 
      :title => "仅自己可见")}
        </span>]
    end

  end

  def reply_email(comment)
    case comment.commentable_type
    when "Wines::Detail"
      link_to "返回", wine_comments_url(comment.commentable)
    when "Winery"
      link_to "返回", winery_comments_url(comment.commentable)
    when "Photo"
      photo = comment.commentable
      case photo.imageable_type
      when "Wines:Detail"
        link_to "返回", wine_photo_url(photo.imageable, photo)
      when "Wine"
        link_to "返回", wine_photo_url(photo.imageable.details.releast_detail.first, photo)
      when "Winery"
        link_to "返回", winery_photo_url(photo.imageable, photo)
      when "Album"
        link_to "返回", album_photo_show_user_url(photo.user, photo.album, photo)
      end
    end
  end

  #使用第三方账号登陆iWine
  def resource_name
    :user
  end

  def resource
    @resource ||= User.new
  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end

  def sns_come_from(type)
    type == "weibo" ? "新浪微博" : (type == "qq" ? "腾讯微博" : "豆瓣")
  end

  #展示关注文本
  def follow_content(parent)
    if current_user && parent.follows.where("user_id = #{current_user.id}").present?
      "取消关注"
    else
      "关注"
    end
  end

  #获取随机数
  def get_rand_id(actor_type, actor_id)
    chars = ("0".."9").to_a
    newpass = ""
    1.upto(6){|i| newpass << chars[rand(chars.size-1)]}
    "#{actor_type.gsub('::Detail', '')}#{actor_id}#{newpass}"
  end

  #首页展示不同文字
  def time_line_text(type, winery = false)
    case type
    when "new_comment"
      "有了新评论"
    when "new_follow"
      "这支酒#{'庄' if winery}被关注"
    when "add_to_cellar"
      "有人把它加入了酒窖"
    end
  end

  def note_radio_button(hash_values, name, current_value, has_li = false)
  table_label = ""
    hash_values.select{|key, val| val.present?}.each do |key, value|
      table_label << "<li>" if has_li
      table_label << %Q[<label>#{radio_button_tag("note[#{name}]", key, current_value == key)}\
        #{value}</label>]
      table_label << "</li>" if has_li
    end
    table_label
  end
  #share_id 从jiathis网站获取
  def link_to_jiathis_share(title, summary, url, image_url, share_id)
    sns_params = {:webid => share_id, :title => title, :summary => summary, :url => url, :pic => image_url, :uid => "1623461"}
    url = %Q[http://www.jiathis.com/send/?#{sns_params.to_param}]
    span_class = case share_id
    when "tsina"
      "icon_sina2"
    when "tqq"
      "icon_tt2"
    when "renren"
      "icon_renren"
    when "douban"
      'icon_douban'
    end
    link_to url, :target => "_blank" do
      content_tag :span, nil, :class => span_class
    end
  end
  
  #暂时使用此方法解决在erb 模版中出现空格的情况。
  def content_no_space(title, summary, url, image_url, float, no_content)
    content = no_content ? nil : "分享到："
    whole_tag = ""
    whole_tag << content.to_s
    share_ids = (float == "right" ? ["renren", "douban", "tqq", "tsina"] : ["tsina", "tqq", "douban", "renren"])
    share_ids.each do |share_id|
      whole_tag << link_to_jiathis_share(title, summary, url, image_url, share_id)
    end
    whole_tag
  end
end
