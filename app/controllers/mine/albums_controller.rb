class Mine::AlbumsController < ApplicationController
  before_filter :authenticate_user!
  
  def upload
    if request.post?
      photo = Photo.new
      photo.image = params[:photo][:image]
      photo.owner_type = OWNER_TYPE_USER
      photo.business_id = current_user.id
      photo.album_id = params[:album_id]
      photo.save

      album = Album.find params[:album_id]
      album.photos_num +=1
      album.save

      render :text => photo.id.to_s 
    end

    @albums = current_user.albums
    
    if @albums.blank?
      avatar_album = Album.create :created_by => current_user.id , :name => 'avatar', :owner_type => OWNER_TYPE_USER
      default_album = Album.create :created_by => current_user.id , :name => 'other', :owner_type => OWNER_TYPE_USER
      @albums = [avatar_album, default_album]
    end

    @select_album_id = params[:album_id] || @albums[0].id
    
  end

end