# encoding: UTF-8
class WinesController < ApplicationController
  before_filter :authenticate_user!, :except => [:index, :show]
  before_filter :set_current_user
  before_filter :get_wine_detail, :except => [:comment_vote]

  ## TODO: 这个action为演示用， 使用后可以删除
  def preview
    render :layout => false

  end

  def index
    @wines = Wines::Detail.includes(:wine, :cover).order("created_at ASC").page params[:page] || 1
  end

  def show
    @wine_detail = Wines::Detail.includes( :covers, :photos, :statistic,  { :wine => [:style, :winery]} ).find( params[:wine_detail_id].to_i )
    @wine = @wine_detail.wine
    @wine_statistic = @wine_detail.statistic || @wine_detail.build_statistic
    # @comments =  Comment.all(:include => [:user], 
    #    :joins => :votes, 
    #    :select => "comments.*, count(votes.id) as votes_count", 
    #    :conditions => "commentable_id=#{@wine_detail_id}", 
    #    :group => "comments.id", 
    #    :order => "votes_count DESC")
    @comments  =  Comment.all(:include => [:user], 
    :joins => :votes,  
    :select => "comments.*, count(votes.id) as votes_count", 
    :conditions => ["commentable_id=?", @wine_detail.id ], :group => "comments.id", 
    :order => "votes_count DESC, created_at DESC", :limit => 6)
    @owners = Users::WineCellarItem.all(:include => [:user], 
    :conditions => ["wine_detail_id = ?", @wine_detail.id], 
    :order => "number DESC, created_at DESC", :limit => 4)
    
    # @wine_comments = @wine_detail.best_comments( 6 )
    # @user_comment = @wine_detail.comment current_user.id
  end

  def upload_photo

  end

  def photos

  end

  def new_short_comment
    @wine_detail = Wines::Detail.find params[:wine_detail_id]

    if @wine_detail.blank?
      return
    end

    @wine = @wine_detail.wine
    @wine_statistic = @wine_detail.statistic
    @user_comment = @wine_detail.comment current_user.id

    if @user_comment.blank?
      @user_comment = Wines::Comment.new
      @user_comment.drink_status = 'drank'
      @user_comment.wine_detail_id = @wine_detail.id
      @user_comment.user_id = current_user.id
    end

    if request.post?
      @user_comment.prepare_update
      @user_comment.drink_status = params[:drink_status]
      @user_comment.point = params[:point] || 0
      @user_comment.content = params[:content]
      @user_comment.save
      redirect_to request.referer
      return
    end
    render :layout => false
  end

  def set_short_comment_point
    comment = Wines::Comment.find params[:comment_id]
    if comment.present? && comment.user_id == current_user.id
      comment.prepare_update
      comment.point = params[:point]
      comment.save
    end
    redirect_to request.referer
  end

  def delete_short_comment
    if request.post?
      comment = Wines::Comment.find params[:comment_id]
      if comment.present? && comment.user_id == current_user.id
        comment.prepare_update
        comment.destroy
      end
    end
    redirect_to :action => 'show', :wine_detail_id => comment.wine_detail_id
  end

  def good_short_comment
    comment = Wines::Comment.find params[:comment_id]

    if comment.present? && Users::GoodHitComment.where( :user_id=>current_user.id, :comment_id=>comment.id ).length == 0
      goodhit = Users::GoodHitComment.new :user_id=>current_user.id, :comment_id=>comment.id
      comment.good_hit +=1
      comment.save
      goodhit.save
    end

    redirect_to request.referer
  end

  def short_comments
    order = params[:order] == 'time' ? 'created_at' : 'good_hit'

    @wine_comments = Wines::Comment
    .includes([:user, :avatar, :user_good_hit])
    .where(["wine_detail_id = ?", params[:wine_detail_id]])
    .order("#{order} DESC,id DESC")
    .page params[:page] || 1

    @wine_detail = Wines::Detail.find params[:wine_detail_id]
    @wine = @wine_detail.wine
    @user_comment = @wine_detail.comment current_user.id
  end

  def long_comments

  end

  def list

  end

  # 关注
  def follow

    if request.get?
      @comment = @wine_detail.current_user_follow(current_user)
      @comment = @comment.blank? ?  Comment.new : @comment.first
      @comment.do = "follow"
      respond_to do |format|
        format.html { render "comment" }
        format.js   { render "comment" }
      end
    end

    if request.post?
      @comment = build_comment
      if @comment.save
        # TODO
        # 1. 广播
        # 2. 分享到SNS
        notice_stickie("取消关注成功.")
        redirect_to "/wines/show?wine_detail_id=#{@wine_detail.id}"
      end
    end
  end

  # 评论
  def comment
    @comment = Comment.new
    @comment.do = "comment"
    if request.post?
      @comment = build_comment
      if @comment.save
        # TODO
        # 1. 广播
        # 2. 分享到SNS
        notice_stickie("评论成功.")
        redirect_to "/wines/show?wine_detail_id=#{@wine_detail.id}"
      end
    end
  end

  # 取消关注
  def cancle_follow
    follow_items = @wine_detail.current_user_follow(current_user)
    return notice_stickie("您还没有有关注该条目.") if follow_items.blank?
    if follow_items.first.update_attribute("deleted_at", Time.now)
      notice_stickie("取消关注成功.")
      redirect_to "/wines/show?wine_detail_id=#{@wine_detail.id}"
    end
  end

  # 有用
  def comment_vote
    @comment = Comment.find(params[:comment_id])
    @comment.liked_by current_user
    render :json => @comment.likes.size.to_json
  end

  # 添加到酒窖
  def add_to_cellar
    @cellar =  Users::WineCellar.new
    @cellar_item = Users::WineCellarItem.new
  end
  
  # 回复评论
  def comment_reply
    @comment = Comment.find(params[:comment_id])
    if request.post?
      @comment = Comment.find(params[:comment_id])
      @reply_comment = Comment.build_from(@wine_detail, current_user.id, params[:comment][:body], :do => "comment")
      @reply_comment.save
      @reply_comment.move_to_child_of(@comment)
      # render :json => @reply_comment.to_json
      render :json => @comment.children.size.to_json
      # respond_to do |format|
      #   format.js { render :json => @comment }
      # end
    end
  end

  private

  def set_current_user
    User::current_user = current_user || 0
  end

  def get_wine_detail
    wine_detail_id = params[:wine_detail_id]
    @wine_detail = Wines::Detail.find(wine_detail_id)
  end

  def build_comment
    if params[:comment][:do] == "follow"
      @comment = @wine_detail.current_user_follow(current_user)
      @comment = @comment.blank? ?  Comment.new : @comment.first
      @comment.attributes =  params[:comment]
      @comment.commentable_type = @wine_detail.class.base_class.name
      @comment.commentable_id = @wine_detail.id
      @comment.point = params[:rate_value]
      @comment.user_id = current_user.id
      return @comment
    end
    @comment = Comment.build_from(@wine_detail,
                                  current_user.id ,
                                  params[:comment][:body],
                                  :point => params[:rate_value],
                                  :do => params[:comment][:do],
                                  :is_share => params[:comment][:is_share],
                                  :private => params[:comment][:private])
  end

end