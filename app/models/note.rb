# encoding: utf-8
class Note < ActiveRecord::Base

  acts_as_votable

  STATUS_FLAG = {
      :draft => NOTE_DATA['note']['status_flag']['submitted'],
      :published => NOTE_DATA['note']['status_flag']['published']
  }
  mount_uploader :photo, NotePhotoUploader

  attr_accessible :name, :orther_name, :vintage, :rating, :location, :grape, :alcohol, :price,
                  :comment, :appearance_clarity, :appearance_intensity, :appearance_color, :appearance_other,
                  :nose_condition, :nose_intensity, :nose_development, :nose_aroma, :palate_sweetness, :palate_acidity,
                  :palate_alcohol, :palate_tannin_level, :palate_tannin_nature, :palate_body, :palate_flavor_intensity,
                  :palate_flavor, :palate_length, :palate_other, :conclusion_quality, :conclusion_reason, :drinkable_begin_at,
                  :drinkable_end_at, :conclusion_other,:crop_x, :crop_y, :crop_w, :crop_h, :appearance_clarity_a, :user_agent,
                  :appearance_clarity_b, :palate_tannin_nature_a, :palate_tannin_nature_b, :palate_tannin_nature_c, :exchange_rate_id,
                  :user_id, :app_note_id

  attr_accessor :crop_x, :crop_y, :crop_w, :crop_h, :drinkable_end, :drinkable_begin, :appearance_clarity_a,
                :appearance_clarity_b, :palate_tannin_nature_a, :palate_tannin_nature_b, :palate_tannin_nature_c
  include Common

  after_save :crop_photo
  before_save :set_modifie_date
  belongs_to :user
  belongs_to :style, :class_name => "Wines::Style", :foreign_key => :wine_style_id
  belongs_to :wine_detail, :class_name => "Wines::Detail", :foreign_key => :wine_detail_id
  belongs_to :exchange_rate
  has_many :comments, :class_name => "NoteComment", :as => :commentable
  has_many :follows, :as => :followable
  validates :uuid, :name, :vintage, :presence => true
  validates :comment, :presence => true, :on => :update
  validates :uuid, :uniqueness => true
  scope :find_app_note, lambda {|app_note_id| where(:app_note_id => app_note_id)}

  def is_followed_by?(user)
    Follow.where(:followable_type => "Note", :followable_id => app_note_id, :user_id => user.id).first ? true : false
  end

  
  def self.local_note(app_note_id)
    Note.find_app_note(app_note_id).first
  end
  
  #用主要的数据创建包含少数信息的note
  def self.init_main_data(info)
    note = Note.find_app_note(info['id']).first
    unless note
      local_note = Note.new(:user_id => info['uid'], :app_note_id => info['id'])
      local_note.sync_main_data(info)
    end
  end
 
  #初始化主要数据，如果api有调整则需要调整此处。
  def sync_main_data(info)
    self.location = info['location']
    self.name = info['sName']
    self.other_name = info['oName']
    self.comment = info['comment']
    self.vintage = info['vintage']
    self.rating = info['rating'].to_i + 1
    self.modifiedDate = info['modifiedDate']
    self.status_flag = info['statusFlag']
    self.uuid = info["notesId"]
    #sync_photo(info)  #此处暂不同步图片，以加快加载速度。
    self.save
  end

  #分享到 sns 的内容
  def share_name
    ""
  end

  def sns_summary(share_url)
    "【iWine.com品酒辞推荐】 #{show_vintage} #{name}#{star_content} #{sns_content} #{share_url}"
  end

  def sns_content
    comment.mb_chars[0, 70] if comment.present?
  end
  
  #星级
  def star_content
    " #{rating}星 " if rating.to_i > 0
  end

  def show_vintage
    vintage.to_i == -1 ? "NV" : vintage
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

  def publish
    if status_flag.to_i == NOTE_DATA['note']['status_flag']['submitted']
      self.update_attribute(:status_flag, NOTE_DATA['note']['status_flag']['published'])
      post_form
    else
      return true
    end
  end
  
  #删除并同步到app
  def delete_note
    #已删除的则不再删除
    if delete_flag.to_i == NOTE_DATA['note']['delete_flag']['unremove']
      self.update_attribute(:delete_flag, NOTE_DATA['note']['delete_flag']['removed'])
      delete_note_from_app
    else
      return true
    end
  end

  def delete_note_from_app
    response = response = Notes::NotesRepository.delete_note(self)
    if response && response['state']
      true
    else
      self.update_attribute(:delete_flag, NOTE_DATA['note']['delete_flag']['unremove'])
      return false
    end
  end

  def init_basic_data_from_app(app_note)
    if app_note #检测是否成功获取来自app的数据。
      if app_note['wine']['detail']
        wine_detail = Wines::Detail.find(app_note['wine']['detail'])
        init_basic_data_from_wine_detail wine_detail
      else
        sync_wine_detail_info app_note['wine']
      end
    end
  end

  
  def init_basic_data_from_wine_detail(wine_detail)
    self.name = wine_detail.wine.origin_name
    self.other_name = wine_detail.wine.name_zh
    self.vintage = wine_detail.is_nv? ? -1 : wine_detail.year.to_s(:year)
    self.region_tree_id = wine_detail.wine.region_tree_id
    self.wine_style_id = wine_detail.wine.wine_style_id
    self.wine_detail_id = wine_detail.id
    self.grape = self.upload_variety_percentage
    self.alcohol = wine_detail.alcoholicity.delete("%") if wine_detail.alcoholicity
  end
 
  #根据app_note_id 初始化数据到local database
  def self.sync_note_base_app_note_id(app_note_id)
    result = Notes::NotesRepository.find(app_note_id)
    if result['state']
      note = Note.new(:app_note_id => app_note_id, :user_id => result['data']['uid'])
      note.sync_data(result['data'])
      Note.find_by_app_note_id(app_note_id)
    end
  end
  
  #将app数据同步到本地数据库。
  def sync_data(app_note)
    return false if !self.new_record? && (self.modifiedDate.to_s(:app_time) == app_note['modifiedDate'])
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
    variety_percentages = self.wine_detail.try(:variety_percentages)
    if variety_percentages.present?
      variety_percentages.each_with_index do |v, i|
        percentage = v.percentage.present? ? v.percentage.gsub("%", '') : 0
        variety_and_percentages << "#{v.variety_id}:#{percentage};"
      end
      variety_and_percentages.gsub(/;$/, '')
    else
      grape
    end
  end

  def color
    if appearance_color.present?
      WineColor.where(:key => appearance_color).first
    end
  end

  def color_to_json
    c = WineColor.where(:key => appearance_color)
    if c.present?
      c.each {|trait| trait.mark_select }.to_json(:methods => :select)
    end
  end

  def noses
    if nose_aroma.present?
      nose_arr = nose_aroma.split(";")
      WineTrait.where(:key => nose_arr)
    end
  end

  def noses_to_json
    if noses.present?
      noses.each {|trait| trait.mark_select }.to_json(:methods => :select)
    end
  end

  def nose_ids
    if noses
      noses.pluck(:id).join(',')
    end
  end

  def traits
    if palate_flavor.present?
      trait_arr = palate_flavor.split(";")
      WineTrait.where(:key => trait_arr)
    end
  end

  def traits_to_json
    if traits.present?
      traits.each {|trait| trait.mark_select }.to_json(:methods => :select)
    end
  end


  def trait_ids
    if traits
      traits.pluck(:id).join(',')
    end
  end

  def followers_count
    Follow.where(:followable_type => 'Note', :followable_id => app_note_id).count
  end

  def likes_count
    # new时， 记得将app_note_id 付值给 id
    note = Note.new
    note.id = app_note_id
    note.likes.count
  end

  def comments_count
   Comment.where(:commentable_type => 'Note', :commentable_id => app_note_id).count
  end

  private

  def sync_wine_detail_info(wine_info)
    self.name = wine_info['sName']
    self.other_name = wine_info['oName']
    self.vintage = wine_info['vintage']
    self.region_tree_id = wine_info['region']
    self.wine_style_id = wine_info['style']
    self.wine_detail_id = wine_info['detail']
    self.grape = wine_info['varienty']
    self.alcohol = wine_info['alcohol'].to_f if wine_info['alcohol'].present?
    # init_variety_percentage(wine_info['detail'], wine_info['varienty']) if wine_info['detail'].present?
  end

  # def init_variety_percentage(detail, variety)
  #   if detail.present? && variety.present?
  #     variety_arr = variety.split(";")
  #     variety_all = []
  #     variety_arr.each do |v|
  #       variety_id_arr = v.split(":")
  #       percentage = variety_id_arr[1].to_i == 0 ? nil : variety_id_arr[1]
  #       variety_all << {:id => variety_id_arr[0], :percentage => percentage}
  #     end
  #     Wines::VarietyPercentage.sync_app_variety(Wines::Detail.find(detail), variety_all)
  #   end
  # end

  def sync_flags(app_note)
    self.delete_flag = app_note['deleteFlag']
    self.status_flag = app_note['statusFlag']
  end

  def sync_basic_info(basic_info)
    self.app_note_id = basic_info['id']
    self.location = basic_info['location']['location'] if basic_info['location']
    self.price = basic_info['wine']['price']
    self.comment = basic_info['wine']['comment']
    self.rating = basic_info['wine']['rating'].to_i + 1
    self.uuid = basic_info['notesId']
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
      begin
        pre = 'http://'
        host = NOTE_HTTP['host']
        port = NOTE_HTTP['port']
        base_url = NOTE_HTTP['image']['base_url']
        version = NOTE_HTTP['image']['version']
        photo_url = "#{pre}#{host}:#{port}/#{base_url}/#{version}/#{image['image'].gsub(/,$/, '')}"
        self.remote_photo_url = photo_url
      rescue OpenURI::HTTPError
        puts "sync photo failure."
      end
    end
  end

end