# encoding: utf-8
class UsersController < ApplicationController
  # before_filter :authenticate_user!
  before_filter :get_user, :except => [:register_success]
  before_filter :get_recommend_users, :only => [:followings, :followers, :start]
  def show
    @followers = @user.followers
    @followings = @user.followings
    @comments = @user.comments.real_comments.limit(6)
    @cellar_items = @user.cellar.items.limit(6)
    @following_wines = @user.wine_followings.limit(6)
  end

  # 关注的酒
  def wine_follows
    @comments = @user.wine_followings.page(params[:page] || 1).per(10)
    @hot_wines = Wines::Detail.hot_wines(5)
  end

  # 关注的酒庄
  def winery_follows
    @comments = @user.winery_followings.page(params[:page] || 1).per(10)
    @hot_wines = Wines::Detail.hot_wines(5)
  end

  # 我的评论
  def comments
    @hot_wines = Wines::Detail.hot_wines(5)
    @comments = @user.comments.real_comments.page(params[:page] || 1).per(10)
  end

  def followings
    @followings = @user.followings.page(params[:page] || 1).per(10)
    # @recommend_users = @user.remove_followings_from_user User.all :conditions =>  "id <> "+ @user.id.to_s , :limit => 5
  end

  def followers
    @followers = @user.followers.page(params[:page] || 1).per(10)
    # @recommend_users = @user.remove_followings_from_user User.all :conditions =>  "id <> "+ @user.id.to_s , :limit => 5
  end

  # 用户第一次登录
  def start
    if current_user.sign_in_count == 1
      @hot_wines = Wines::Detail.hot_wines(6)
      if request.post?

        # follow wines
        if params[:wine_detail_ids].present?
          params[:wine_detail_ids].each do |wine_detail_id|
            follow_one_wine(wine_detail_id)
          end
        end # end wines

        # follow users
        if params[:user_ids].present?
          params[:user_ids].each do |user_id|
            follow_one_user(user_id)
          end
        end # end users

        # 填充用户的Home内容
        current_user.init_events_from_followings

        redirect_to(home_index_path)
      end # end post
    else
      redirect_to home_index_path
    end
  end

  private
  def get_user
    @user = User.find(params[:id])
  end

  # 关注某支酒
  def follow_one_wine(wine_detail_id)
    wine_detail = Wines::Detail.find(wine_detail_id)
    follow = current_user.follow_wine(wine_detail)
    follow.save
  end

  # 关注某个人
  def follow_one_user(user_id)
    current_user.follow_user(user_id)
  end

  def get_recommend_users
    @recommend_users = User.no_self_recommends(5, @user.id)
  end
end
