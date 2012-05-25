# encoding: utf-8
class UsersController < ApplicationController
  # before_filter :authenticate_user!
  before_filter :get_user, :except => [:register_success]

  def show
    @followers = @user.followers
    @followings = @user.followings
    @comments = @user.comments.limit(6)
    @cellar_items = @user.cellar.items.limit(6)
    @following_wines = @user.wine_followings.limit(6)
  end

  # 关注的酒
  def wine_follows
    @comments = @user.wine_followings.page(params[:page] || 1).per(10) 
    @hot_wines = Wines::Detail.hot_wines(:limit => 5)
  end

  # 关注的酒庄
  def winery_follows
    @comments = @user.winery_followings.page(params[:page] || 1).per(10) 
    @hot_wines = Wines::Detail.hot_wines(:limit => 5)
  end

  # 我的评论
  def comments
    @hot_wines = Wines::Detail.hot_wines(:limit => 5)
    @comments = @user.comments.page(params[:page] || 1).per(10) 
  end

  def followings
    @followings = @user.followings.page(params[:page] || 1).per(10)
    # TODO: 这里的算法有问题， 请更新, 应该算出被follow最多的用户
    @recommend_users = @user.remove_followings_from_user User.all :conditions =>  "id <> "+ @user.id.to_s , :limit => 5
    # @recommend_users = current_user.remove_followings_from_user User.all :conditions =>  "id <> "+current_user.id.to_s , :limit => 5
  end

  def followers
    @followers = @user.followers.page(params[:page] || 1).per(10)
    # TODO: 这里的算法有问题， 请更新, 应该算出被follow最多的用户
    @recommend_users = @user.remove_followings_from_user User.all :conditions =>  "id <> "+ @user.id.to_s , :limit => 5
    # @recommend_users = current_user.remove_followings_from_user User.all :conditions =>  "id <> "+current_user.id.to_s , :limit => 5
  end

  private
  def get_user
    @user = User.find(params[:id])
  end

end
