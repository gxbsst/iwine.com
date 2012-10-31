class Album < ActiveRecord::Base
  belongs_to :user, :foreign_key => 'created_by'
  has_many :images, :class_name => "Photo", :dependent => :destroy
  has_many :photos, :as => :imageable
  has_many :covers, :as => :imageable, :class_name => "Photo", :conditions => { :photo_type => APP_DATA["photo"]["photo_type"]["cover"] }

  scope :public, where('is_public=1')
  scope :private, where('is_public=0')

  validates :name, :presence => true

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
 
  def all_photo_comments_count
    images.sum(:comments_count)
  end

  def all_photo_views_count
    images.sum(:views_count)
  end

  def all_photo_votes_count
    images.sum(:votes_count)
  end
end
