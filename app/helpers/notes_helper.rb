# encoding: utf-8
module NotesHelper
  def cover(photo, version = 'normal', pattern = '', size = '590x590')
    if photo.images.is_a? Array
      image_tag(photo.images(:version => version, :pattern => pattern).first, :size => size)
    else
      image_tag(photo.images(:version => version, :pattern => pattern), :size => size)
    end
  end

  def appearance_color_img(color_string)
    color_string
  end

  def appearance_color_text(color_string)
    color_string
  end

  def show_color(color_name)
  return '无' if color_name.blank?
   image_tag("color/#{color_name}.png")
  end

  def wine_style(style)
    return '无' if style.blank?
    Wines::Style.find(style).name_zh
  end

  def nose_aroma(aroma)
    return '无' if aroma.blank?
    html = ''
    aroma.split(';').compact.each do |i|
      html <<  %Q[ <li> #{image_tag("nose/#{i}.png", :size => '128x128')} <br /> #{NOTE_TRAIT['zh'][i]} </li>]
    end
    html
  end

  def trait_img_tag(trait_key)
    image_tag("nose/#{trait_key}.png", :size =>'128x128' )
  end

  ## 显示评星
  #def star_rate_tag(point)
  #  point ||= 0
  #  gray_num = 5 - point
  #  html = ""
  #  point.times do |i|
  #    html << (image_tag 'base/star_red.jpg', :width=>15, :height=>14)
  #  end
  #  gray_num.times do |i|
  #    html << (image_tag 'base/star_gray.jpg', :width=>15, :height=>14)
  #  end
  #  return html.html_safe
  #end

  def price(price)
    return '无' if price.blank?
    price.to_s + '元'
  end

  def alcohol(alcohol)
    return '无' if (alcohol.blank? || alcohol.to_i==0)
    number_to_percentage(alcohol, :precision => 0)
  end

  def drinkwindow(drinkwindow)
    return '无' if drinkwindow.blank?
    drinkwindow
  end

  def varieties(varieties)
    return '无' if varieties.blank?
    new_array = []
    varieties.split(';').each do |variety|
      variety_item = variety.split(':')
      variety_record = Wines::Variety.find(variety_item[0])
      new_array <<  "#{variety_record.origin_name}/#{variety_record.name_zh} #{number_to_percentage(variety_item[1], :precision => 0)}"
    end
    new_array.join("<br />")
  end

  def show_color_image(color)
    if color
      %Q[<li><img src="/assets/color/#{color.image}" size="128×128" alt="#{color.name_zh}"</img>
          <br/>#{color.name_zh}  <a href="javascript:void(0)" class="remove">x</a></li>]
    end
  end

  def nose_and_trait_images(noses)
    if noses.present?
      image_labels = ""
      noses.each do |nose|
        image_labels << %Q[<li><img src="/assets/nose/#{nose.key}.png" size="128×128" alt="#{nose.name_zh}"</img>
          <br/>#{nose.name_zh}  <a href="javascript:void(0)" class="remove">x</a></li>]
      end
      image_labels
    end
  end

  def show_draft_button(note, options = {})
    if note.new_record? || note.status_flag == NOTE_DATA['note']['status_flag']['submitted']
      %Q[<a id="#{options[:id]}" class="#{options[:class]}" href="javascript:void(0);">
        <span>保存为草稿</span></a>]
    end
  end

end
