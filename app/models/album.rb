class Album < ActiveRecord::Base

  belongs_to :user, :foreign_key => 'created_by'

  has_many :photos


  def cover
    cover = Photo.first :conditions => {:album_id => id, :is_cover => true}

    if cover.blank?
      cover = Photo.first :conditions => { :album_id => id }
    end
 
    cover
  end
end