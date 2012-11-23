class Note < ActiveRecord::Base
  mount_uploader :photo, NotePhotoUploader

  attr_accessible :name, :orther_name, :vintage, :rating, :location, :grape, :alcohol, :price,
    :comment, :appearance_clarity, :appearance_intensity, :appearance_color, :appearance_other,
    :nose_condition, :nose_intensity, :nose_development, :nose_aroma, :palate_sweetness, :palate_acidity,
    :palate_alcohol, :palate_tannin_level, :palate_tannin_nature, :palate_body, :palate_flavor_intensity,
    :palate_flavor, :palate_length, :palate_other, :conclusion_quality, :conclusion_reason, :drinkable_begin_at,
    :drinkable_end_at, :conclusion_other,:crop_x, :crop_y, :crop_w, :crop_h, :appearance_clarity_a, :user_agent,
    :appearance_clarity_b, :palate_tannin_nature_a, :palate_tannin_nature_b, :palate_tannin_nature_c

  attr_accessor :crop_x, :crop_y, :crop_w, :crop_h, :drinkable_end, :drinkable_begin, :appearance_clarity_a,
    :appearance_clarity_b, :palate_tannin_nature_a, :palate_tannin_nature_b, :palate_tannin_nature_c
  include Common

  before_create :init_uuid
  after_save :crop_photo
  before_save :set_modifie_date
  belongs_to :user
  belongs_to :style, :class_name => "Wines::Style", :foreign_key => :wine_style_id
  belongs_to :wine_detail, :class_name => "Wines::Detail", :foreign_key => :wine_detail_id
  belongs_to :exchange_rate
  validates :photo, :presence => true
  def init_uuid
    #如果本地没有note,新建note时使用从app得到的uuid
    self.uuid = SecureRandom.uuid if self.new_record? && user_agent.to_s == NOTE_DATA['note']['user_agent']['local']
  end
  def show_vintage
    is_nv ? "NV" : vintage
  end

  def show_alcohol
    "#{alcohol}%Vol" if alcohol.present?
  end

  def drinkwindow
    if drinkable_begin_at.present? || drinkable_end_at.present?
      drinkable_begin = drinkable_begin_at.present? ? drinkable_begin_at : "?"
      drinkable_end = drinkable_end_at.present? ? drinkable_end_at : "?"
      "#{drinkable_begin}~#{drinkable_end}"
    end
  end

  def resize_photo(from_version, to_version)
    params =  APP_DATA["image"]["note"]["#{to_version.to_s}"]["width"].to_s << "x" <<  APP_DATA["image"]["note"]["#{to_version.to_s}"]["height"].to_s
    source_path = Rails.root.to_s << "/public" << photo.url(from_version)
    target_path = Rails.root.to_s << "/public" <<  photo.url(to_version)
    image = MiniMagick::Image.open(source_path)
    image.resize(params)
    image.write(target_path)
  end

  def set_modifie_date
    self.modifiedDate = Time.now
  end

  def crop_photo
    if crop_x.present?
      photo.recreate_versions!
      # Crop之后，重新生成缩略图
      resize_photo(:large, :middle_x)
      resize_photo(:large, :middle)
      resize_photo(:large, :thumb)
    end
  end
  
  #将app数据同步到本地数据库。
  def sync_data(app_note)
    return false if self.modifiedDate.to_s(:app_time) == app_note['modifiedDate']
    sync_wine_detail_info app_note['wine']
    sync_basic_info app_note
    sync_photo app_note['cover']
    sync_conclusion app_note['conclusion']
    sync_appearance app_note['appearance']
    sync_nose app_note['nose']
    sync_palate app_note['palate']
    sync_flags app_note
    self.save
  end
 
 #上传用户剪切好的图片
  def byte_array_image
    if photo.present?
      photo_string = photo.large.read
      ActiveSupport::Base64.encode64(photo_string)
    end
  end

  #将本地数据提交到服务器上
  def post_form
    response = Notes::NotesRepository.post_note(self)
    if response && response['state']
      self.update_attribute(:app_note_id, response['id']) if self.app_note_id.blank?
      return true
    else
      return false
    end
  end

  def upload_variety_percentage
    variety_and_percentages = ""
    variety_percentages = self.wine_detail.variety_percentages
    if variety_percentages.present?
      variety_percentages.each_with_index do |v, i|
        percentage = v.percentage.present? ? v.percentage.gsub("%", '') : 0
        variety_and_percentages << "#{v.variety_id}:#{percentage};"
      end
      variety_and_percentages.gsub(/;$/, '')
    end
  end
  
  private

  def sync_wine_detail_info(wine_info)
    self.name = wine_info['sName']
    self.other_name = wine_info['oName']
    if wine_info['vintage'].present? && wine_info['vintage'].to_s.include?("NV")
      self.is_nv  = true
    else
      self.vintage = wine_info['vintage']
    end
    self.region_tree_id = wine_info['region']
    self.wine_style_id = wine_info['style']
    self.wine_detail_id = wine_info['detail']
    init_variety_percentage(wine_info['detail'], wine_info['varienty'])
  end

  def init_variety_percentage(detail, variety)
    if detail.present? && variety.present?
      variety_arr = variety.split(";")
      variety_hash = {}
      variety_arr.each do |v|
        variety_id_arr = v.split(":")
        percentage = variety_id_arr[1].to_i == 0 ? nil : variety_id_arr[1]
        variety_hash.merge! :variety_id => variety_id_arr[0], :percentage => percentage
      end
      Wines::VarietyPercentage.sync_app_variety(Wines::Detail.find(detail), variety_hash)
    end
  end

  def sync_flags(app_note)
    self.delete_flag = app_note['deleteFlag']
    self.status_flag = app_note['statusFlag']
  end

  def sync_basic_info(basic_info)
    self.user_agent = NOTE_DATA['note']['user_agent']['app']
    self.location = basic_info['location']['location']
    self.price = basic_info['wine']['price']
    self.comment = basic_info['wine']['comment']
    self.alcohol = basic_info['wine']['alcohol'].to_f if basic_info['wine']['alcohol'].present?
    self.rating = basic_info['wine']['rating'].to_i + 1 
  end

  def sync_conclusion(conclusion)
    self.conclusion_quality = conclusion['quality']
    self.conclusion_reason = conclusion['reason']
    sync_drinkable(conclusion['drinkwindow'])
    self.conclusion_other = conclusion['other']
  end

  def sync_appearance(appearance)
    self.appearance_intensity = appearance['intensity']
    self.appearance_clarity = appearance['clarity']
    self.appearance_other = appearance['other']
    self.appearance_color = appearance['color']
  end

  def sync_nose(nose)
    self.nose_condition = nose['condition']
    self.nose_intensity = nose['intensity']
    self.nose_development = nose['development']
    self.nose_aroma = nose['aroma']
  end

  def sync_palate(palate)
    self.palate_sweetness = palate['sweetness']
    self.palate_acidity = palate['acidity']
    self.palate_alcohol = palate['alcohol']
    self.palate_tannin_level = palate['tanninLevel']
    self.palate_tannin_nature = palate['tanninNature']
    self.palate_body = palate['body']
    self.palate_flavor_intensity = palate['flavorIntensity']
    self.palate_flavor = palate['flavor']
    self.palate_length = palate['length']
    self.palate_other = palate['other']
  end
  
  #处理酒的适饮年限
  def sync_drinkable(drinkwindow)
    if drinkwindow.present?
      drinkable_arr = drinkwindow.split("~")
      return if drinkable_arr.size == 0
      self.drinkable_begin_at = drinkable_arr[0].include?('?') ? nil : drinkable_arr[0].strip
      self.drinkable_end_at = drinkable_arr[1].include?('?') ? nil : drinkable_arr[1].strip
    end
  end
  
  #通过图片超链接更新本地图片
  def sync_photo(image)
    if image.present? && image['image'].present?
      host = "#{NOTE_DATA['note']['photo_location']['host']}"
      base_url = "#{NOTE_DATA['note']['photo_location']['base_url']}"
      version = "#{NOTE_DATA['note']['photo_location']['version']}"
      photo_url = "#{host}/#{base_url}/#{version}/#{image['image'].gsub(/,$/, '')}"
      self.remote_photo_url = photo_url
    end
  end

end