# encoding: utf-8
class FollowsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :get_user
  before_filter :get_followable
  before_filter :check_followed, :only => :create
  # before_filter :get_follow, :only => [:destroy]

  def new
    @follow = @followable.follows.build
  end

  def create
    @follow = build_follow
    if @follow.save
      notice_stickie t("notice.comment.follow_success")
      redirect_to params[:return_url] ?  params[:return_url] : @followable_path
    end
  end

  def destroy
    @follow = get_user_follow_item
    if @follow.destroy
      notice_stickie t("notice.comment.cancle_follow")
      redirect_to params[:return_url] ?  params[:return_url] : @followable_path
    end
  end

  private

  def get_followable
    @resource, @id = request.path.split('/')[1, 2]
    @followable_path = eval(@resource.singularize + "_path(#{@id})")
    @resource = "Wines::Detail" if @resource == "wines"
    @followable = @resource.singularize.classify.constantize.find(@id)
  end

  def check_followed
    if @followable.is_followed_by?(@user)
      notice_stickie t("notice.comment.cancle_follow")
      redirect_to(@followable_path)
    end
  end

  def get_user
    @user = current_user
  end

  def get_follow
    @follow = Follow.find(params[:id])
  end

  def build_follow
    @resource, @id = request.path.split('/')[1, 2]
    values = params[(@resource.singularize + "_follow").to_sym]
    @follow = @followable.follows.build(values)
    @follow.user_id = @user.id
    @follow
  end

  def get_user_follow_item
    @follow = @followable.follows.where(:user_id => @user.id).first
  end
end
