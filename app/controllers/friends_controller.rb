# -*- coding: utf-8 -*-
class FriendsController < ApplicationController
  before_filter :authenticate_user!

  # 查找好友
  def find
    @availabe_sns = current_user.available_sns
  end

  def search
    @search = Search.find(params[:id])
    @users = User.where("username like ? and id != ?", "%#{@search.keywords}%", current_user.id).order("followers_count desc")
    @user_ids = @users.pluck(:id).join(",")
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
end
