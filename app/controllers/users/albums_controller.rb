class Users::AlbumsController < PhotosController
  before_filter :authenticate_user!, :except => ['show' , 'list' , 'photo']

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

  def show
    @album = Album.find params[:album_id]
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
    @photo = Photo.find params[:photo_id]

    @photo = Photo.first :conditions => ''

    @album = @photo.album
    @user = @album.user
    @count = Photo.count :conditions => '`album_id`=' + @album.id.to_s + ' and `id` > ' + @photo.id.to_s
  end

  def edit
    @album = Album.first :conditions => { :id => params[:album_id] , :created_by => current_user.id }

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

  def list
    check_owner

    @albums = Album 
      .where(["created_by= ?", @user.id])
      .order("id DESC")
      .page params[:page] || 1

  end

  def check_owner
    if params[:user_id].blank?
      if user_signed_in?
        @album_user_id = current_user.id
        @is_owner = true
      else
        redirect_to :login
      end
    else
      @album_user_id = params[:user_id].to_i
      if user_signed_in? && @album_user_id == current_user.id
        @is_owner = true
      else
        @is_owner = false
      end
    end

    @user = User.find @album_user_id
  end
end