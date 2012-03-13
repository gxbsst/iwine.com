class Users::AlbumsController < ApplicationController
  before_filter :authenticate_user!

  def upload
    if request.post?
      photo = Photo.new
      photo.image = params[:photo][:image]
      photo.owner_type = OWNER_TYPE_USER
      photo.business_id = current_user.id
      photo.album_id = params[:album_id]
      photo.save
      render :text => photo.id.to_s 
    end

    @albums = current_user.albums
    if @albums.blank?
      avatar_album = Album.create :created_by => current_user.id , :name => 'avatar', :owner_type => OWNER_TYPE_USER
      default_album = Album.create :created_by => current_user.id , :name => 'other', :owner_type => OWNER_TYPE_USER
      @albums = [avatar_album, default_album]
    end
  end

  def upload_list
    @photos = Photo.all :conditions => { :id => params[:photo_ids].split(',') }
  end

  def save_upload_list
    photos = Photo.all :conditions => { :id => params[:photo].keys , :album_id => params[:album_id]}
    cover = Photo.first :conditions => { :album_id => params[:album_id] , :is_cover => true }

    photos.each do |photo|
      if params[:photo][photo.id.to_s].present?
        photo.intro = params[:photo][photo.id.to_s]
      end
      if photo.id === params[:cover_id].to_i
        photo.is_cover = true;
      end

      photo.save
    end

    if cover.present?
      cover.is_cover = false;
      cover.save
    end
    if params[:deleted_ids].present?
      Photo.delete params[:deleted_ids].split(',')
    end

    redirect_to :action => 'show', :album_id => params[:album_id]
  end

  def new
    if request.post?
      album = Album.new
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

  def delete

    render :layout => false
  end

  def delete_photo

    render :layout => false
  end

  def show
    @album = Album.find params[:album_id]

  end

  def photo
    @photo = Photo.find(params[:id])
  end

  def edit

  end
end