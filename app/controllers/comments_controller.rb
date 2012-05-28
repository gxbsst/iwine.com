# encoding: utf-8
class CommentsController < ApplicationController
  before_filter :authenticate_user!, :except => [:index, :show, :list]
  before_filter :get_comment, :only => [:show, :edit, :update, :destroy, :reply, :vote]
  before_filter :get_commentable
  before_filter :get_user
  before_filter :check_followed, :only => :create
  before_filter :check_cancle_follow, :only => :cancle_follow
  def new   
    if params[:do].present? && params[:do] == "follow"
      new_follow_comment
    else
      new_normal_comment
    end   
  end
  
  def index
    case params[:sort_by]
    when "hot"
      order = "votes_count DESC, created_at DESC"
    when "new"
      order = "created_at DESC, votes_count DESC"
    else
      order = "votes_count DESC, created_at DESC"
    end
    @comments  =  @commentable.comments.all(:include => [:user],
    # :joins => :votes,
    :joins => "LEFT OUTER JOIN `votes` ON comments.id = votes.votable_id",
    :select => "comments.*, count(votes.id) as votes_count",
    :conditions => ["parent_id IS NULL"], :group => "comments.id",
    :order => order )
    page = params[:params] || 1

    if !(@comments.nil?)
      unless @comments.kind_of?(Array)
        @comments = @comments.page(page).per(8)
      else
        @comments = Kaminari.paginate_array(@comments).page(page).per(10)
      end
    end

    new_normal_comment

    case @resource
      when "Wines::Detail"
        render_wine_comments
      when "wineries"
        render_winery_comments
    end

  end
  
  # 评论
  def create
    @comment = build_comment
    if @comment.save
      # TODO
      # 1. 广播
      # 2. 分享到SNS
      notice_stickie("评论成功.")
      redirect_to params[:return_url] ?  params[:return_url] : @commentable_path
    end
  end
  
  def update
    @comment = build_comment
    if @comment.save
      # TODO
      # 1. 广播
      # 2. 分享到SNS
      notice_stickie("取消关注成功.")
      redirect_to "/wines/show?wine_detail_id=#{@wine_detail.id}"
    end
  end

  # 取消关注
  def cancle_follow
    follow_item = @commentable.find_follow @user
    if follow_item.update_attribute("deleted_at", Time.now)
      notice_stickie("取消关注成功.")
      redirect_to @commentable_path
    end
  end

  # 有用
  def vote
    @comment.liked_by @user
    render :json => @comment.likes.size.to_json
  end

  # 回复评论
  def reply
    if request.post?
      @reply_comment = ::Comment.build_from(@comment.commentable,
      @user.id,
      params[:comment][:body],
      :parent_id => @comment.id,
      :do => "comment")
      @reply_comment.save
      @reply_comment.move_to_child_of(@comment)
      render :json =>  @comment.children.all.size.to_json
    end
  end

  private
  
  def get_commentable
    @resource, @id = request.path.split('/')[1, 2]
    @commentable_path = eval(@resource.singularize + "_path(#{@id})")
    @resource = "Wines::Detail" if @resource == "wines"
    @commentable = @resource.singularize.classify.constantize.find(@id)
  end
  
  def new_follow_comment
    @comment = @commentable.comments.build
    @comment.do = "follow"
  end
  
  def new_normal_comment
    @comment = @commentable.comments.build
    @comment.do = "comment"    
  end

  def build_comment
    @resource, @id = request.path.split('/')[1, 2]
    values = params[(@resource.singularize + "_comment").to_sym]
    values["point"] = params[:rate_value] if params[:rate_value].present?
    # TODO： point这个字段要做保护处理，以免用户回复时也会更新point
    @comment = @commentable.comments.build(values)
    @comment.user_id = @user.id
    return @comment
  end

  def get_comment
    @comment = Comment.find(params[:id])
  end
  
  def get_user
    @user = current_user
  end

  def check_followed
    if params[:do] == "follow" && @commentable.is_followed?(@user)
      redirect_to(@commentable_path, :notice => "已经关注过")
    end
  end

  def check_cancle_follow
    if params[:do] == "follow" && !@commentable.is_followed?(@user)
      redirect_to(@commentable_path, :notice => "请先关注")
    end
  end

  def render_wine_comments
    @wine_detail = @commentable
    @wine = @wine_detail.wine
    render "wine_comments_list"
  end
  def render_winery_comments
    @winery = @commentable
    @hot_wines = Wines::Detail.hot_wines(:order => "desc", :limit => 5)
    @users = @winery.followers(:limit => 16)#关注酒庄的人
    render "winery_comments_list"
  end
end
