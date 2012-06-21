# encoding: utf-8
class PhotosController < ApplicationController
  before_filter :get_photo, :only => [:show, :edit, :update, :destroy, :reply, :vote]
  before_filter :get_imageable, :except => [:new, :create]
  before_filter :get_user
  before_filter :authenticate_user!, :only => [:new, :create]
  def index
    @photos = @imageable.photos.approved.page(params[:page] || 1).per(8)
    case @resource
      when "Wines::Detail"
      # 包括detail和wine的图片
      @photos =  @imageable.all_photos.page(params[:page] || 1).per(8)
      render_wine_photo_list
    when "wineries"
      render_winery_photo_list
    end
  end

  def show
    @photo.update_attribute(:views_count, @photo.views_count + 1)
    new_normal_comment
    order = "votes_count DESC, created_at DESC"
    @comments  =  @photo.comments.all(:include => [:user],
    # :joins => :votes,
    :joins => "LEFT OUTER JOIN `votes` ON comments.id = votes.votable_id",
    :select => "comments.*, count(votes.id) as votes_count",
    :conditions => ["parent_id IS NULL"], :group => "comments.id",
    :order => order )
    page = params[:params] || 1

    case @resource
    when "Wines::Detail"
      render_wine_photo_detail
    when "wineries"
      render_winery_photo_detail
    end
  end
  
  def vote
    @photo.liked_by @user
     render :json => @photo.likes.size.to_json
  end

  def new
    @title = "上传图片"
    @user = current_user
    @albums = @user.albums
    if @albums.blank?
       @albums.create!([{:user_id => @user.id, :name => "酒"},
                        {:user_id => @user.id, :name => "酒庄"},
                        {:user_id => @user.id, :name => "其他"},])
    end
    @album_id = params[:album_id] ||  @albums.first.id
    @photo = Photo.new
  end

  def create
      @user = current_user
      # 多图片上传
      params[:photo][:image].each do |image|
        @photo = create_photo(image)
        if @photo.save
          respond_to do |format|
          format.html {                                         #(html response is for browsers using iframe sollution)
            render :json => [@photo.to_jq_upload].to_json,
            :content_type => 'text/html',
            :layout => false
          }
          format.json {
            render :json => [@photo.to_jq_upload].to_json
          }
        end
      else
        render :json => [{:error => "custom_failure"}], :status => 304
      end
    end
  end

  def destroy

    
  end

  private

  def get_imageable
    @resource, @id = request.path.split('/')[1, 2]
    @commentable_path = eval(@resource.singularize + "_path(#{@id})")
    @resource = "Wines::Detail" if @resource == "wines"
    @imageable = @resource.singularize.classify.constantize.find(@id)
  end

  def get_photo
    @photo = Photo.approved.where("id = ?", params[:id]).first
    render(:status => 404) unless @photo
  end

  def get_user
    @user = current_user
  end

  def new_normal_comment
    @commentable = @photo
    @comment = @commentable.comments.build
    @comment.do = "comment" 
    return @comment   
  end

  def render_wine_photo_detail
    # @comment = @commentable.comments.build
    @wine_detail = Wines::Detail.find(params[:wine_id])
    @wine = @wine_detail.wine
    @title = ["图片", @wine_detail.name].join('-')
    render "wine_photo_detail"
  end

  def render_winery_photo_detail
    find_winery_and_hot_winery
    @multiple = true #此页面有两个分享
    @title = ["图片", @winery.name].join('-')
    render "winery_photo_detail"

  end

  def render_wine_photo_list
    @wine_detail = Wines::Detail.find(params[:wine_id])
    @wine = @wine_detail.wine
    @title = ["图片", @wine_detail.name].join('-')
    render "wine_photo_list"
  end

  def render_winery_photo_list
    find_winery_and_hot_winery
    @title = ["图片", @winery.name].join('-')
    render "winery_photo_list"
  end

  def find_winery_and_hot_winery
    @winery = Winery.find params[:winery_id]
    @hot_wineries = Winery.hot_wineries(5) 
  end

  def get_photo_imageable
    if params[:wine_id].present?
      @resource, @id = ["Wines::Detail", params[:wine_id]]
    elsif params[:winery_id].present?
      @resource, @id = ["Winery", params[:winery_id]]
    else
      @resource, @id = ["Album",  params[:album_id]]
    end
    @imageable = @resource.singularize.classify.constantize.find(@id)
  end

  def create_photo(image)
    @imageable = get_photo_imageable
    @photo = @imageable.photos.build
    @photo.album_id = params[:album_id]
    @photo.image = image
    @photo.user_id = @user.id
    return @photo    
  end

end