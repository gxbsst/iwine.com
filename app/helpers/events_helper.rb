module EventsHelper
  include ActsAsTaggableOn::TagsHelper
  def tags_cloud(*arg)
   tags = Event.tag_counts_on(:tags, :limit => 30 )
   html = ''
   tags.each do |tag|
     html << (content_tag :li, (link_to_tag tag.name))
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
end
