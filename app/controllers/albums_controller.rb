# encoding: utf-8
class AlbumsController < ApplicationController
  before_filter :authenticate_user!, :except => [:show, :index, :photo]
  before_filter :get_user
  before_filter :get_album, :except => [:index, :upload, :new, :delete_photo, :update_photo_intro]

  def upload
    @albums = @user.albums
    if @albums.blank?
      @albums.create!([{:user_id => @user.id, :name => "酒"},
        {:user_id => @user.id, :name => "酒庄"},
        {:user_id => @user.id, :name => "其他"},])
      end
      @album_id = params[:album_id] ||  @albums.first.id
      if request.post?
        @photo = create_photo
        @photo.save
        render :text => @photo.id.to_s
      end
    end

    def upload_list
      @photos = Photo.all :conditions => { :id => params[:photo_ids].split(',') }
    end

    def save_upload_list
      photos = Photo.all :conditions => { :id => params[:photo].keys , :album_id => params[:id] }
      cover = Photo.first :conditions => { :album_id => params[:id] , :is_cover => true }
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
      redirect_to '/mine/albums/'+params[:id]
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
        photo.destroy if photo && photo.user_id == @user.id
        redirect_to request.referer
        return
      end
      render :layout => false
    end

    def edit
      redirect_to request.referer if @album.blank?
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
      redirect_to request.referer if @album.blank?
      if user_signed_in? && current_user.id == @user.id
        @is_owner = true;
      else
        @is_owner = false;
      end
      # order = params[:order] === 'time' ? 'created_at' : 'liked_num';
      order = 'created_at'
      @photos = Photo
      .where(["album_id= ?", params[:id]])
      .order("#{order} DESC,id DESC")
      .page params[:page] || 1
    end

    def photo
      redirect_to request.referer if @album.blank?
      order = "votes_count DESC, created_at DESC"
      @photo = Photo.find(params[:photo_id])
      @photo.update_attribute(:views_count, @photo.views_count + 1)
      @comments  =  @photo.comments.all(:include => [:user],
      # :joins => :votes,
      :joins => "LEFT OUTER JOIN `votes` ON comments.id = votes.votable_id",
      :select => "comments.*, count(votes.id) as votes_count",
      :conditions => ["parent_id IS NULL"], :group => "comments.id",
      :order => order )
      page = params[:params] || 1
      @commentable = @photo
      new_normal_comment
      @other_albums = @user.albums.where("id != #{@album.id}")
    end

    def index
      @user = current_user
      @albums = Album .where(["created_by= ?", current_user.id]).order("id DESC").page params[:page] || 1
    end

    def vote
      @album.liked_by @user
      render :json => @album.likes.size.to_json
    end

    private

    def get_user
      @user = User.find(params[:id] || current_user.id)
    end

    def get_album
      @album = @user.albums.find(params[:id] || params[:album_id])
    end

    def get_imageable
      if params[:wine_id].present?
        @resource, @id = ["Wines::Detail", params[:wine_id]]
      elsif params[:winery_id].present?
        @resource, @id = ["Winery", params[:winery_id]]
      else
        @resource, @id = ["Album",  params[:album_id]]
      end
      @imageable = @resource.singularize.classify.constantize.find(@id)
    end

    def create_photo
      @imageable = get_imageable
      @photo = @imageable.photos.build
      @photo.album_id = params[:album_id]
      @photo.image = params[:photo][:image]
      @photo.user_id = @user.id
      return @photo    
    end
    
    def new_normal_comment
       @comment = @photo.comments.build
       @comment.do = "comment" 
       return @comment   
     end

  end
