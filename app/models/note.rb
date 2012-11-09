class Note < ActiveRecord::Base
  mount_uploader :photo, NotePhotoUploader
  attr_accessible :name, :orther_name
  attr_accessor :crop_x, :crop_y, :crop_w, :crop_h
  include Common
  belongs_to :user
  belongs_to :style, :class_name => "Wines::Style", :foreign_key => :wine_style_id
  belongs_to :wine_detail, :class_name => "Wines::Detail", :foreign_key => :wine_detail_id
  belongs_to :exchange_rate



  def show_vintage
    is_nv ? "NV" : vintage
  end

  def show_alcohol
    "#{alcohol}%Vol" if alcohol.present?
  end
end