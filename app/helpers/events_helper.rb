#encoding: utf-8
module EventsHelper
  include ActsAsTaggableOn::TagsHelper
  def tags_cloud(*arg)
   tags = Event.tag_counts_on(:tags, :limit => 30 )
   html = ''
   tags.each do |tag|
     if params[:tag] == tag.name
       html << (content_tag :li, (link_to_tag tag.name), :class => :select)
     else
       html << (content_tag :li, (link_to_tag tag.name))
     end
   end
   html.html_safe
  end

  def static_date_tags
    html = ''
    {
      :recent_week => '最近一周',
      :today => '今天',
      :tomorrow => '明天',
      :weekend => '周末'
    }.each do |key, value|
      if params[:date] == key.to_s
        html << (content_tag :li, link_to_date_tag(value, :date => key), :class => :select)
      else
        html << (content_tag :li, link_to_date_tag(value, :date => key))
      end
    end
    html.html_safe
  end

  def link_to_tag(tag, options = {})
   link_to tag, events_path(:tag => tag), options 
  end

  def event_item_tags(event)
    html = ''
    event.tag_list.each do |tag|
      html << (link_to_tag(tag) + " ")
    end
    html.html_safe
  end

  def link_to_date_tag(name, params, options = {})
   link_to name, events_path(params), options
  end

  def city_tags
    html = ''
    APP_DATA['event']['city'].each do |key, value|
      if params[:city] == key
        html << (content_tag :li, link_to_date_tag(key, :city => key), :class => :select)
      else
        html << (content_tag :li, link_to_date_tag(key, :city => key))
      end
    end
    html.html_safe
  end

  def event_event_comments_path(commentable, comment)
    event_comments_path(commentable, comment)
  end
end
