class Album < ActiveRecord::Base
  belongs_to :user, :foreign_key => 'created_by'
  has_many :images, :class_name => "Photo"
  has_many :photos, :as => :imageable
  acts_as_votable

  #使用photos 的scope
  #def cover
  #  cover = Photo.first :conditions => {:album_id => id, :is_cover => true}
  #  if cover.blank?
  #    cover = Photo.first :conditions => { :album_id => id }
  #  end
  #  cover
  #end

  def position photo_id
    Photo.count( :conditions => '`album_id`=' + id.to_s + ' and `id` > ' + photo_id.to_s ) + 1
  end

  def photo index
    index = 0 if index < 0
    Photo.first :conditions => { :album_id => id } , :order => 'id DESC' , :offset => index , :limit => 1
  end
  
end