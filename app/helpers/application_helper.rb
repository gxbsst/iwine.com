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

end
