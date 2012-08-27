# encoding: utf-8
class CommentsController < ApplicationController
  before_filter :authenticate_user!, :except => [:index, :show, :list]
  before_filter :get_comment, :only => [:show, :edit, :update, :destroy, :reply, :vote, :children]
  before_filter :get_commentable, :except => [:vote, :reply, :children]
  before_filter :get_user
  before_filter :get_follow_item, :only => [:index]

  # before_filter :check_followed, :only => :create
  # before_filter :check_cancle_follow, :only => :cancle_follow
  before_filter :check_can_comment, :only => :create
  after_filter  :send_reply_email, :only => :reply
<<<<<<< Updated upstream
=======

  def show
    page = params[:page] || 1
    @reply_comments = Comment.reply_comments(@comment.id).page(page).per(8)
    case @comment.commentable_type
    when "Wines::Detail"
      render_wine_comment_detail
    when "Winery"
      render_winery_comment_detail
    when "Photo"
      photo_imageable_type = @comment.commentable.imageable_type
      @photo = @comment.commentable
      case photo_imageable_type
      when "Album"
        render_album_photo_comment_detail
      when "Wine", "Wines::Detail"
        render_wine_photo_comment_detail
      when "Winery"
        render_winery_photo_comment_detail
      end
    when 'Event'
      render_event_comment_detail
    end
  end

  def get_sns_reply
    @reply_list = @comment.get_sns_comments
    respond_to do |format|
      format.js
    end
  end

>>>>>>> Stashed changes
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
    page = params[:page] || 1

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
      notice_stickie t("notice.comment.#{@comment.do == 'follow' ? 'follow' : 'comment'}_success")
      redirect_to params[:return_url] ?  params[:return_url] : @commentable_comments_path
    end
  end
  
  def update
    @comment = build_comment
    if @comment.save
      # TODO
      # 1. 广播
      # 2. 分享到SNS
      redirect_to "/wines/show?wine_detail_id=#{@wine_detail.id}"
    end
  end

  # # 取消关注
  # def cancle_follow
  #   follow_item = @commentable.find_follow @user
  #   if follow_item.update_attribute("deleted_at", Time.now)
  #     notice_stickie t("notice.comment.cancle_follow")
  #     redirect_to @commentable_path
  #   end
  # end

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
      @success_create = true #for after_filter(send_reply_email)
    end
  end

  # 子评论列表
  def children
    @children = @comment.children_and_order
  end

  private
  
  def get_commentable
    @resource, @id = request.path.split('/')[1, 2]
    @resource_path = @resource 
    @resource = "Wines::Detail" if @resource == "wines"
    @commentable = @resource.singularize.classify.constantize.find(@id)
     # @commentable_path = eval(@wine_resource.singularize + "_path(#{@commentable.id})")
    @commentable_path = self.send("#{@resource_path.singularize}_path", @commentable)
    @commentable_comments_path = self.send("#{@resource_path.singularize}_comments_path", @commentable)
    @commentable
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

  # def check_followed
  #   if params[:do] == "follow" && @commentable.is_followed?(@user)
  #     notice_stickie t("notice.comment.cancle_follow")
  #     redirect_to(@commentable_path)
  #   end
  # end

  # def check_cancle_follow
  #   if params[:do] == "follow" && !@commentable.is_followed?(@user)
  #     notice_stickie t("notice.comment.check_cancle_follow")
  #     redirect_to(@commentable_path)
  #   end
  # end

  def render_wine_comments
    @wine_detail = @commentable
    @wine = @wine_detail.wine
    render "wine_comments_list"
  end
  def render_winery_comments
    @winery = @commentable
    # @hot_wines = Wines::Detail.hot_wines(5)
    @hot_wineries = Winery.hot_wineries(5) 
    @users = @winery.followers(:limit => 16) #关注酒庄的人
    render "winery_comments_list"
  end

  #用户评论设置
  def check_can_comment
    #只检查用户相册的照片是否有权限评论
    if @commentable.class.name == "Photo" && @commentable.imageable_type == "Album"
      user = @commentable.user
      if current_user != user  #跳过用户自己评论自己的照片
        if user.profile.config.notice.comment.to_i == 2 && !current_user.is_following(user)#2只有关注的人才能评论自己，1所有人
          notice_stickie t("notice.comment.check_can_comment")
          redirect_to params[:return_url] ?  params[:return_url] : @commentable_path
        end
      end
    end
  end
  
  #评论用户的照片发送邮件提醒
  def send_reply_email
    if @success_create && @reply_comment.parent_id
      @parent_comment = Comment.find(@reply_comment.parent_id)
      user = @parent_comment.user 
      if user && user.profile.config[:notice][:email].include?("2") #用户设置发送邮件 
        UserMailer.reply_comment(:parent_user => user, :reply_user => @user, :parent_comment => @parent_comment, :children => @parent_comment.children.limit(5).reorder("id DESC")).deliver
      end
    end
  end

  # 登录用户是否关注酒或者酒庄
  def get_follow_item
    if !user_signed_in? 
      nil
    else
      if @follow_item = (@commentable.is_followed_by? current_user)
        @follow_item 
      else
        nil
      end
    end
  end

  #show render选项
  def render_wine_comment_detail
    @wine_detail = @comment.commentable
    @wine = @wine_detail.wine      
    render "wine_comment_detail"
  end

  def render_winery_comment_detail
    @winery = @comment.commentable
    @hot_wineries = Winery.hot_wineries(5)
    @users    = @winery.followers #关注酒庄的人
    render "winery_comment_detail"
  end
  
  def render_album_photo_comment_detail
    @album = @comment.commentable.imageable
    @user = @album.user
    @other_albums = @user.albums.where("id != #{@album.id}")
    render "album_photo_comment_detail" 
  end
  
  #需要区分wine还是detail
  def render_wine_photo_comment_detail
    if @comment.commentable.imageable_type == "Wines::Detail"
      @wine_detail = @comment.commentable.imageable
      @wine = @wine_detail.wine
    else
      @wine = @comment.commentable.imageable
      @wine_detail = @wine.get_latest_detail
    end
    render "wine_photo_comment_detail"
  end

  def render_winery_photo_comment_detail
    @winery = @comment.commentable.imageable
    @hot_wineries = Winery.hot_wineries(5)
    render "winery_photo_comment_detail"
  end

  def render_event_comment_detail
    @event = @comment.commentable
    @recommend_events = Event.recommends(4)
    render "event_comment_detail"
  end
end
