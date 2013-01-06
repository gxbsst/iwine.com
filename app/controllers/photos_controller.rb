# encoding: utf-8
class PhotosController < ApplicationController
  before_filter :get_imageable, :except => [:new, :create, :vote]
  before_filter :get_approved, :only => [:show]
  before_filter :get_photo, :only => [:edit, :update, :destroy, :reply]
  before_filter :get_user
  before_filter :authenticate_user!, :only => [:new, :create]
  before_filter :get_follow_item, :only => [:show, :index]
  before_filter :check_and_create_albums, :only => :new

  def index
    @title = "照片"
    @photos = @imageable.photos.approved.page(params[:page] || 1).per(8)
    case @resource
      when "Wines::Detail"
      # 包括detail和wine的图片
      @wine_notes_count = @imageable.get_wine_notes_count(@imageable.id)
      @photos =  @imageable.all_photos.page(params[:page] || 1).per(8)
      render_wine_photo_list
    when "wineries"
      render_winery_photo_list
    when "events"
      render_event_photo_list
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
    # page = params[:params] || 1
    page = params[:page] || 1
    @comments =  @photo.comments.page(page).per(20)

    case @resource
    when "Wines::Detail"
      render_wine_photo_detail
    when "wineries"
      render_winery_photo_detail
    when "events"
      render_event_photo_detail
    end
  end

  def vote
    @photo = Photo.find(params[:id])
    if(@photo)
      @photo.liked_by @user
      render :json => @photo.likes.size.to_json
    else
      render_404('')
    end
  end

  def new
    @title = "上传图片"
    @photo = Photo.new
  end

  def create
    @user = current_user
    # 多图片上传
    params[:photo][:image].each do |image|
      @photo = create_photo(image)
      if @photo.save
        @photo.approve_photo
        respond_to do |format|
          format.html { #(html response is for browsers using iframe sollution)
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

  def update

    # set as cover 
    if @photo.is_owned_by? current_user
      if params[:is_cover].present? && params[:is_cover].to_i == APP_DATA["photo"]["photo_type"]["cover"].to_i
        Photo.where(:album_id => @photo.album_id)
          .update_all(:photo_type => APP_DATA["photo"]["photo_type"]["normal"])
        @photo.update_column(:photo_type, APP_DATA["photo"]["photo_type"]["cover"])
      end
    end
    respond_to do |format|
       format.js { render :json => {:id => params[:id]} }
    end
  end

  private

  def get_imageable
    @resource, @id = request.path.split('/')[1, 2]
    @resource_path = @resource 
    # @commentable_path = eval(@resource.singularize + "_path(#{@id})")
    @resource = "Wines::Detail" if @resource == "wines"
    @imageable = @resource.singularize.classify.constantize.find(@id)
    @imageable_path = self.send("#{@resource_path.singularize}_path", @imageable)
  end

  def get_approved
    #需要同时展示wine和wine_detail的照片
    if @imageable.class.name == "Wines::Detail"
      @photo = @imageable.all_photos.where("id = ?", params[:id]).first
    else
      @photo = @imageable.photos.approved.where("id = ?", params[:id]).first
    end
    render_404('') unless @photo
  end

  def get_photo
    @photo = @imageable.photos.find(params[:id])
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

  def render_event_photo_detail
    @multiple = true # 此页面有两个分享
    init_event_object
    render "event_photo_detail"
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

  def render_event_photo_list
    init_event_object
    render "event_photo_list"
  end

  def find_winery_and_hot_winery
    @winery = Winery.find params[:winery_id]
    @hot_wineries = Winery.hot_wineries(5) 
  end

  def init_event_object
    @event = Event.find(params[:event_id])
    @recommend_events = Event.recommends(4)
    @participant = @event.have_been_joined? @user.id if @user
  end

  def get_photo_imageable(image)
    #上传酒并选择保存到相册里时同时创建两个photo记录，并返回保存到相册中
    if params[:wine_id].present?
      @resource, @id = ["Wines::Detail", params[:wine_id]]
      create_no_album_photo(Wines::Detail.find(params[:wine_id]), image) if params[:album_id]
    elsif params[:winery_id].present?
      @resource, @id = ["Winery", params[:winery_id]]
      create_no_album_photo(Winery.find(params[:winery_id]), image) if params[:album_id]
    elsif params[:event_id].present?
      @resource, @id = ["Event", params[:event_id]]
      create_no_album_photo(Event.find(params[:event_id]), image) if params[:album_id]
    end
    @resource, @id = ["Album",  params[:album_id]] if params[:album_id]
    @imageable = @resource.singularize.classify.constantize.find(@id)
  end

  def create_photo(image)
    @imageable = get_photo_imageable(image)
    @photo = @imageable.photos.build
    @photo.album_id = params[:album_id] || -1 #上传酒或酒庄图片
    @photo.image = image
    @photo.user_id = @user.id
    return @photo
  end
  
  def create_no_album_photo(imageable, image)
    photo = imageable.photos.build(:album_id => -1, :image => image, :user_id => @user.id)
    photo.save
    photo.approve_photo
  end

  # 登录用户是否关注酒或者酒庄
  def get_follow_item
    if !user_signed_in? 
      nil
    else
      if @follow_item = (@imageable.is_followed_by? current_user)
        @follow_item 
      else
        nil
      end
    end
  end

end
