class PhotosController < ApplicationController
  before_filter :get_photo, :only => [:show, :edit, :update, :destroy, :reply, :vote]
  before_filter :get_imageable
  before_filter :get_user

  def index
    @photos = @imageable.photos.page(params[:page] || 1).per(8)
    case @resource
    when "Wines::Detail"
      render_wine_photo_list
    when "Winery"
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
    when "Winery"
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
    @comment = @imageable.comments.build
    @comment.do = "comment" 
    return @comment   
  end

  def render_wine_photo_detail
    @commentable = @photo
    @comment = @commentable.comments.build
    @wine_detail = Wines::Detail.find(params[:wine_id])
    @wine = @wine_detail.wine
    render "wine_photo_detail"
  end

  def render_winery_photo_detail
    render "winery_photo_detail"
  end

  def render_wine_photo_list
    @wine_detail = Wines::Detail.find(params[:wine_id])
    @wine = @wine_detail.wine
    render "wine_photo_list"
  end

  def render_winery_photo_list
    render "winery_photo_list"
  end

end