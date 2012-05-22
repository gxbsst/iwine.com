class WineDetails::PhotosController < ApplicationController
   before_filter :get_photo, :except => [:index]
   before_filter :get_wine_detail
   before_filter :get_commentable
   before_filter :get_user
   
  def index
     @photos = @wine_detail.photos.page(params[:page] || 1).per(8)
  end

  def show
    new_normal_comment
    order = "votes_count DESC, created_at DESC"
    @comments  =  @commentable.comments.all(:include => [:user],
    # :joins => :votes,
    :joins => "LEFT OUTER JOIN `votes` ON comments.id = votes.votable_id",
    :select => "comments.*, count(votes.id) as votes_count",
    :conditions => ["parent_id IS NULL"], :group => "comments.id",
    :order => order )
    page = params[:params] || 1
    
  end

  private
  def get_photo
    @photo = Photo.find(params[:id])
  end
  def get_wine_detail
    @wine_detail = Wines::Detail.find(params[:wine_id])
    @wine = @wine_detail.wine
  end
  
  def new_normal_comment
    @comment = @commentable.comments.build
    @comment.do = "comment" 
    return @comment   
  end
  
  def get_commentable
     @commentable = @photo
  end
  
  def get_user
    @user = current_user
  end
  
end
