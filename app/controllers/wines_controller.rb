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

  # Wine Profile
  def show
    @wine             = @wine_detail.wine
    @comments         = @wine_detail.all_comments(:limit => 6)
    @owners           = @wine_detail.owners(:limit => 4)
    @followers        = @wine_detail.followers(:limit => 11)
    # @wine_statistic = @wine_detail.statistic || @wine_detail.build_statistic
  end

  # 关注者
  def followers
    @wine             = @wine_detail.wine
    @followers = @wine_detail.followers
  end

  # 拥有者
  def owners
    @wine             = @wine_detail.wine
    @owners = @wine_detail.owners
  end

  # 添加到酒窖
  def add_to_cellar
    @cellar =  Users::WineCellar.new
    @cellar_item = Users::WineCellarItem.new
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

