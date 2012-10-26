# Attributes:
# * id [integer, primary, not null, limit=4] - primary key
# * commented_num [integer, default=0, limit=4] - TODO: document me
# * cover_id [integer, default=0, limit=4] - TODO: document me
# * created_at [datetime, not null] - creation time
# * created_by [integer, not null, limit=4] - belongs to User
# * deleted_at [datetime] - TODO: document me
# * intro [text] - TODO: document me
# * is_order_asc [boolean, not null, limit=1] - TODO: document me
# * liked_num [integer, default=0, limit=4] - TODO: document me
# * name [string, not null]
# * photos_count [integer, default=0, limit=4] - TODO: document me
# * photos_num [integer, default=0, limit=4] - TODO: document me
# * updated_at [datetime, not null] - last update time
# * user_id [integer, limit=4] - TODO: document me
# * viewed_num [integer, default=0, limit=4] - TODO: document me
class Album < ActiveRecord::Base
  belongs_to :user, :foreign_key => 'created_by'
  has_many :images, :class_name => "Photo", :dependent => :destroy
  has_many :photos, :as => :imageable
  has_many :covers, :as => :imageable, :class_name => "Photo", :conditions => { :photo_type => APP_DATA["photo"]["photo_type"]["cover"] }

  acts_as_votable
  counts :photos_count => {:with => "Photo",
                           :receiver => lambda {|photo| photo.album }, 
                           :increment => {:on => :create, :if => lambda {|photo| photo.album_id > 0}},
                           :decrement => {:on => :save,   :if => lambda {|photo| photo.album_id > 0 && !photo.deleted_at.blank? }}                              
                          }

  #使用photos 的scope
  # def cover
  #  cover = Photo.first :conditions => {:album_id => id, :is_cover => true}
  #  if cover.blank?
  #    cover = Photo.first :conditions => { :album_id => id }
  #  end
  #  cover
  # end

  def position photo_id
    Photo.count( :conditions => '`album_id`=' + id.to_s + ' and `id` > ' + photo_id.to_s ) + 1
  end

  def photo index
    index = 0 if index < 0
    Photo.first :conditions => { :album_id => id } , :order => 'id DESC' , :offset => index , :limit => 1
  end

end
