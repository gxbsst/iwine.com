class Users::AlbumsController < ApplicationController
  before_filter :authenticate_user!

  def show

  end

  def upload
    if request.post?
      photo = Photo.new
      photo.image = params[:photo][:image]
      photo.owner_type = OWNER_TYPE_USER
      photo.business_id = current_user.id
      photo.album_id = params[:album_id]
      photo.save
      render :text => 'done'
    end

    @albums = current_user.albums
    if @albums.blank?
      avatar_album = Album.create :created_by => current_user.id , :name => 'avatar', :owner_type => OWNER_TYPE_USER
      default_album = Album.create :created_by => current_user.id , :name => 'other', :owner_type => OWNER_TYPE_USER

      @albums = [avatar_album, default_album]
    end
  end

  def new
    if request.post?
      album = Album.new
      binding.pry
      album.attributes = params[:album]
      album.created_by = current_user.id
      album.owner_type = OWNER_TYPE_USER
      album.save

      redirect_to request.referer
      return
    end
    @album = Album.new
    render :layout => false
  end
end