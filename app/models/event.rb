class Event < ActiveRecord::Base
  belongs_to :user
  belongs_to :region
  belongs_to :audit_log
  has_many :photos, :as => :imageable
  has_many :wines, :class_name => "EventWine"
  has_many :participants, :class_name => "EventParticipant"
  has_many :invitees, :class_name => "EventInvitee"
  has_many :comments,  :class_name => 'EventComment', :as => :commentable
  has_many :followers, :as => :followable, :class_name => "EventFollow"

  attr_accessible :address, :begin_at, :block_in, :description, :end_at, :followers_count,
  :latitude, :longitude, :participants_count, :poster, :pulish_status, :title,
  :crop_x, :crop_y, :crop_w, :crop_h

  attr_accessor :crop_x, :crop_y, :crop_w, :crop_h
  
  validates :title, :tag_list, :address, :begin_at, :end_at,  :presence => true

  acts_as_taggable
  acts_as_taggable_on :tags

  # process address longitude & latitude
  geocoded_by :address

  # Upload Poster 
  mount_uploader :poster, PosterUploader

  before_save :set_geometry

  # Crop poster
  after_update :crop_poster

  private

  def set_geometry
    geometry = self.poster.large.geometry
    if (! geometry.nil?)
      self.poster_width = geometry[:width]
      self.poster_height = geometry[:height]
    end
  end

  def resize_poster(from_version, to_version)
    source_path = Rails.root.to_s << "/public" << poster.url(from_version)
    target_path = Rails.root.to_s << "/public" << poster.url(to_version)
    image = MiniMagick::Image.open(source_path)
    image.resize(get_poster_resize_params(to_version))
    image.write(target_path)
  end

  def crop_poster
    if crop_x.present?
      poster.recreate_versions!
      resize_poster(:large, :middle)
      resize_poster(:large, :thumb)
    end
  end

  def get_poster_resize_params(version)
    APP_DATA["image"]["poster"]["#{version.to_s}"]["width"].to_s << 
    "x" <<  APP_DATA["image"]["poster"]["#{version.to_s}"]["height"].to_s
  end

end
