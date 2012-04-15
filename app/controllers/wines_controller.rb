# encoding: UTF-8
class WinesController < ApplicationController
  before_filter :authenticate_user!, :except => [:index, :show]
  before_filter :set_current_user

  ## TODO: 这个action为演示用， 使用后可以删除
  def preview

  end

  def index
    @wines = Wines::Detail.includes(:wine, :cover).order("created_at ASC").page params[:page] || 1
  end

  def show
    @wine_detail = Wines::Detail.includes( :cover, :photos, :statistic,  { :wine => [:style, :winery]} ).find( params[:wine_detail_id].to_i )
    @wine = @wine_detail.wine
    @wine_statistic = @wine_detail.statistic || @wine_detail.build_statistic
    @wine_comments = @wine_detail.best_comments( 6 )
    @user_comment = @wine_detail.comment current_user.id
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

  private

  def set_current_user
    User::current_user = current_user || 0
  end
end
