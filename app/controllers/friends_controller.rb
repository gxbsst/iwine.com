# -*- coding: utf-8 -*-
class FriendsController < ApplicationController
  before_filter :authenticate_user!

  def follow
      params[:user_id].split(',').each_with_index do |user_id, index|
        if current_user.is_following( user_id ).blank? && current_user.id != user_id.to_i
          following_user = User.find user_id.to_i
          friendship = Friendship.new
          friendship.user_id = user_id
          friendship.follower_id = current_user.id
          friendship.save
          notice_stickie t("notice.friend.follow") if index == 0 #避免同时关注多人出现多条提示信息
          UserMailer.follow_user(
            :following => following_user, 
            :follower => current_user).deliver if following_user.profile.config[:notice][:email].include? "3" #被关注发送提醒邮件
        end
      end
    redirect_to request.referer
  end

  def unfollow
    friendship = Friendship.first :conditions => { :user_id => params[:user_id] , :follower_id => current_user.id }
    if friendship.present?
      friendship.destroy
      notice_stickie t("notice.friend.unfollow")
    end
    # redirect_to :action => 'find'
    redirect_to request.referer
  end

  # 查找好友
  def find
    @availabe_sns = current_user.available_sns
  end

  def search
    begin
      @search = Search.find(params[:id])
      server = HotSearch.new
      @users = server.search_user(@search.keywords)
      @user_ids = get_user_ids
      page = params[:page] || 1
      if @users.present?
        unless @users.kind_of?(Array)
          @users = @users.page(page).per(10)
        else
          @users = Kaminari.paginate_array(@users).page(page).per(10)
        end
      end
    rescue Exception => e
      logger.error(e)
      notice_stickie t("notice.friend.search_failure")
      redirect_to  find_friends_path
    end
  end

  # 设置同步
  def setting_sns
    @availabe_sns = current_user.available_sns
  end

  def followings
    @followings = current_user.followings
  end

  def sync
    client = current_user.oauth_client( params[:sns_name] )
    @availabe_sns = current_user.available_sns
    @user_ids = []
    if client.present?
      @recommend_friends = current_user.remove_followings client.possible_local_friends
      @authorized = true
      @recommend_friends.each do |f|
        @user_ids.push( f.user_id )
      end
    else
      @authorized = false
    end

  end

  def delete_sns
    user_oauth = Users::Oauth.first :conditions => { :user_id => current_user.id , :sns_name => params[:sns_name] }
    if user_oauth.present?
      user_oauth.delete
    end
    redirect_to request.referer
  end

  def new_sns
    sns_class_name = params[:sns_name].capitalize
    oauth_module = eval( "OauthChina::#{sns_class_name}" )
    client = oauth_module.new
    authorize_url = client.authorize_url
    Rails.cache.write(build_oauth_token_key(client.name, client.oauth_token), client.dump)
    redirect_to authorize_url
  end

  def callback
    sns_class_name = params[:type].capitalize
    oauth_module = eval( "OauthChina::#{sns_class_name}" )
    client = oauth_module.load(Rails.cache.read(build_oauth_token_key(params[:type], params[:oauth_token])))
    client.authorize(:oauth_verifier => params[:oauth_verifier])
    results = client.dump

    if results[:access_token] && results[:access_token_secret]
      flash[:notice] = "done"
    else
      flash[:notice] = "fail"
    end
    # 创建UserOauth记录
    user_oauth = current_user.oauth_token client.name.to_s
    user_oauth.access_token = results[:access_token]
    user_oauth.sns_user_id = client.user_id # sns.rb Sina#user_id
    user_oauth.refresh_token = results[:access_token_secret]
    user_oauth.save

    redirect_to '/friends/sync?sns_name=' + params[:type]
  end

  def sns
    @available_sns = current_user.available_sns
  end

  def from_email

    if request.post?
      @recommend_users = current_user.mail_contacts params[:email], params[:login], params[:password]
    end

  end


  def email_invite
    email_arr = params[:email_address].to_s.split("\n")
    if email_arr.blank?
      notice_stickie t("notice.friend.email_invite")
      redirect_to find_friends_path
    else
      email_arr.each do |email|
        ::UserMailer.invoting_friends(email, params[:description], current_user).deliver
      end
      redirect_to user_path current_user
    end
  end

  private

  def build_oauth_token_key(name, oauth_token)
    [name, oauth_token].join("_")
  end

  def get_user_ids
    if @users.present?
      if @users.kind_of?(Array)
        ids = @users.inject([]){|memo, u| memo << u.id}
      else
        ids = @users.pluck(:id)
      end
      return ids.join(",") #转化为字符串
    end
  end
end
