class PhotosController < ApplicationController
  before_filter :get_photo, :only => [:show, :edit, :update, :destroy, :reply, :vote]
  before_filter :get_imageable
  before_filter :get_user

  def index
    @photos = @imageable.photos.page(params[:page] || 1).per(8)
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

  private

  def get_imageable
    @resource, @id = request.path.split('/')[1, 2]
    @commentable_path = eval(@resource.singularize + "_path(#{@id})")
    @resource = "Wines::Detail" if @resource == "wines"
    @imageable = @resource.singularize.classify.constantize.find(@id)
  end

  def get_photo
    @photo = Photo.find(params[:id])
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
    render "wine_photo_detail"
  end

  def render_winery_photo_detail
    find_winery_and_hot_wine
    @photo = @winery.photos.find(params[:id])
    @multiple = true #此页面有两个分享
    render "winery_photo_detail"
  end

  def render_wine_photo_list
    @wine_detail = Wines::Detail.find(params[:wine_id])
    @wine = @wine_detail.wine
    render "wine_photo_list"
  end

  def render_winery_photo_list
    find_winery_and_hot_wine
    @photos = @winery.photos.order("updated_at desc").page(params[:page] || 1).per(8)
    render "winery_photo_list"
  end

  def find_winery_and_hot_wine
    @winery = Winery.find params[:winery_id]
    @hot_wines = Wines::Detail.hot_wines(5)
  end
end