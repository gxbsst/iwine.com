class Users::AlbumsController < PhotosController
  # before_filter :authenticate_user!, :except => ['show' , 'list' , 'photo']
  before_filter :get_user
  before_filter :get_album, :except => [:index, :upload, :new]
  
  def index
    # @albums = Album .where(["created_by= ?", current_user.id]).order("id DESC").page params[:page] || 1
    @albums = @user.albums.order("id DESC").page params[:page] || 1
    
  end
  
  def show
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

  def list
    check_owner

    @albums = Album 
      .where(["created_by= ?", @user.id])
      .order("id DESC")
      .page params[:page] || 1

  end

  def photo_comment
    if request.post?
      photo_comment = PhotoComment.new
      photo_comment.attributes = params[:photo_comment]
      photo_comment.user_id = current_user.id
      photo_comment.save

      photo = Photo.find photo_comment.photo_id
      album = Album.find photo.album_id
      photo.commented_num += 1
      album.commented_num += 1
      photo.save
      album.save
    end

    redirect_to request.referer
  end
  
  private
  
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
    if @user.blank?
      redirect_to request.referer
    end
  end

  private

  def get_user
    @user = User.find(params[:user_id])
  end

  def direct_current_user
    if @user == current_user
      redirect_to :controller => "mine"
    end
  end
  
  
  def get_album
    @album = @user.albums.find(params[:id])
  end
  
end
