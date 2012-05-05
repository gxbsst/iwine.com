# encoding: utf-8
class UsersController < ApplicationController
  before_filter :get_user, :except => [:register_success]
  before_filter :direct_current_user, :except => [:register_success]

  def index
    @followers = @user.followers
    @followings =@user.followings
    @comments = @user.comments
    render "mine/index"
  end

  # 关注的酒
  def wine_follows
    render "mine/wine_follows"
  end

  # 我的评论
  def comments
    @comments = Wines::Comment.all
    render "mine/comments"
  end

  def testing_notes
    render "mine/testing_notes"
  end

  def followings
    @followings = Friendship
      .includes([:user])
      .where(["follower_id = ?", current_user.id])
      .order("id DESC")
      .page params[:page] || 1

    @recommend_users = current_user.remove_followings_from_user User.all :conditions =>  "id <> "+current_user.id.to_s , :limit => 5

    render "mine/followings"
  end

  def followers
    @followers = Friendship
      .includes([:follower])
      .where(["user_id = ?", current_user.id])
      .order("id DESC")
      .page params[:page] || 1

    @recommend_users = current_user.remove_followings_from_user User.all :conditions =>  "id <> "+current_user.id.to_s , :limit => 5

    render "mine/followers"
  end

  # before_filter :authenticate_user!, :except => [:index, :show, :register_success]
=begin
  def show
    @user = User.find params[:id]
  end

  def profile
    @profile = current_user.user_profile || current_user.build_user_profile
  end

  def avatar
    @photos = current_user.photos
    #@avatar = current_user.avatar
    @photo = Photo.new

    if request.post?
      @photo.image = params[:photo][:image]
      @photo.owner_type = OWNER_TYPE_USER
      @photo.business_id= current_user.id
      @photo.save
    end

    if request.put?
      @photo = Photo.find(params[:id])
      @photo.crop_x = params[:photo][:crop_x]
      @photo.crop_y = params[:photo][:crop_y]
      @photo.crop_w = params[:photo][:crop_w]
      @photo.crop_h = params[:photo][:crop_h]

      @photo.save
      redirect_to '/users/avatar'
      return
    end
  end

  def crop
    @photo = Photo.find params[:id]

    if request.put?
      @photo.attributes = params[:photo]
      @photo.save
      redirect_to '/users/avatar'
      return
    end

    render :layout => false
  end

  def register_success
    @title = "注册成功."
  end
=end
  private

  def get_user
    @user = User.find(params[:user_id])
  end

  def direct_current_user
    if @user == current_user
      redirect_to :controller => "mine"
    end
  end

end
