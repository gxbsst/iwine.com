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
      avatar_album = Album.create :created_by => current_user.id , :name => 'avatar'
      default_album = Album.create :created_by => current_user.id , :name => 'other'
      @albums = [avatar_album, default_album]
    end

    @select_album_id = params[:album_id] || @albums[0].id
  end

  def upload_list
    @photos = Photo.all :conditions => { :id => params[:photo_ids].split(',') }
  end

  def save_upload_list
    photos = Photo.all :conditions => { :id => params[:photo].keys , :album_id => params[:album_id] }
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
      album.save
      redirect_to request.referer
      return
    end
    @album = Album.new
    render :layout => false
  end

  def delete
    if request.post?
      @album = Album.first :conditions => { :id => params[:album_id] , :created_by => current_user.id }

      if @album.present? && @album.name != 'avatar'
        Photo.delete_all '`album_id`=' + @album.id.to_s
        @album.delete
      end

      redirect_to :action => 'index'
      return
    end

    render :layout => false
  end

  def delete_photo

    if request.post?

      photo = Photo.find params[:photo_id]
      if photo && photo.album.created_by == current_user.id
        photo.destroy
      end

      redirect_to request.referer
      return
    end

    render :layout => false
  end

  def edit
    @album = Album.first :conditions => { :id => params[:album_id] , :created_by => current_user.id }
    if @album.blank?
      redirect_to request.referer
    end

    if request.put?
      @album.attributes = params[:album]
      @album.save
      redirect_to :action => 'show' , :album_id => @album.id
    end

    if @album.blank?
      redirect_to :action => 'list'
      return
    end
  end

  def update_photo_intro
    photo = Photo.find params[:photo_id]
    photo.intro = params[:photo]["intro"]
    photo.save

    render :json => photo
  end

  
  def show
    @album = Album.find params[:album_id]

    if @album.blank?
      redirect_to request.referer
    end

    @user = @album.user

    if user_signed_in? && current_user.id == @user.id
      @is_owner = true;
    else
      @is_owner = false;
    end

    order = params[:order] === 'time' ? 'created_at' : 'liked_num';
    
    @photos = Photo
      .where(["album_id= ?", params[:album_id]])
      .order("#{order} DESC,id DESC")
      .page params[:page] || 1
    
  end

  def photo

    @album = Album.find params[:album_id]
    if @album.blank?
      redirect_to request.referer
    end

    if params[:index].to_i < 0
      @index = @album.photos_num - 1
    elsif params[:index].to_i >= @album.photos_num
      @index = 0
    else
      @index = params[:index].to_i
    end

    @photo = @album.photo @index
    @user = @album.user
    @top_albums = @user.top_albums 3
    @photo.viewed_num += 1
    @album.viewed_num += 1
    @photo.save
    @album.save

    @photo_comment = PhotoComment.new
    @photo_comments = PhotoComment.all :conditions => { :photo_id => @photo.id }
  end

  def index
    @albums = Album .where(["created_by= ?", current_user.id]).order("id DESC").page params[:page] || 1
  end
 
end