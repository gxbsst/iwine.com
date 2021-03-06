# -*- coding: utf-8 -*-
class FriendsController < ApplicationController
  before_filter :authenticate_user!

  # 查找好友
  def find
    @title = "找朋友"
    @availabe_sns = current_user.available_sns
  end

  def search
    begin
      @search = Search.find(params[:id])
      server = HotSearch.new
      @search_users = server.search_user(@search.keywords)
      @users = @search_users.to_a.delete_if{|u| u == current_user}
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
    @title = "同步设置"
    @availabe_sns = current_user.available_sns
  end

  def followings
    @followings = current_user.followings
  end


  #新浪微博单独使用oauth2获取粉丝
  def sync
    @availabe_sns = current_user.available_sns
    oauth = current_user.oauths.oauth_binding.where("sns_name = ? ", params[:sns_name]).first
    if oauth
      @recommend_friends = Service::FriendService::Recommend.call(current_user, params[:sns_name])
      @authorized = true
      #@refresh_access_token TODO: 写方法去验证是否过期
    else
      @authorized = false
    end
    #@authorized
    #begin
    #  #找到对应的oauth
    #  oauth = current_user.oauths.oauth_binding.where("sns_name = ? ", params[:sns_name]).first
    #  if params[:sns_name] == "weibo"
    #    @oauth_user = current_user.oauths.oauth_binding.where("sns_name = 'weibo'").first
    #  else
    #    client = current_user.oauth_client( params[:sns_name] )
    #  end
    #  @availabe_sns = current_user.available_sns
    #  @user_ids = []
    #  @recommend_friends = []
    #  if client.present? || @oauth_user
    #    oauth_users = @oauth_user ? current_user.weibo_friends('weibo',
    #                                          @oauth_user.access_token,
    #                                          @oauth_user.sns_user_id) :  client.possible_local_friends(oauth)
    #    if oauth_users.present?
    #      @recommend_friends = current_user.remove_followings oauth_users
    #      @recommend_friends.each do |f|
    #        @user_ids.push( f.user_id )
    #      end
    #    end
    #    @authorized = true
    #  else
    #    @authorized = false
    #  end
    #rescue OAuth2::Error => e
    #  @refresh_access_token = true
    #  notice_stickie t("notice.oauth.refresh_access_token")
    #end
  end

  def delete_sns
    user_oauth = Users::Oauth.oauth_binding.where("user_id = ? and sns_name  = ? ", current_user.id, params[:sns_name]).first
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
    begin
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
      #目前仅用于创建豆瓣
      Users::Oauth.build_binding_oauth(current_user,
        {:sns_name => client.name.to_s,
         :access_token =>  results[:access_token],
         :uid => client.user_id,
         :refresh_token => results[:access_token_secret]
        })
      redirect_to sync_friends_path(:sns_name => params[:type], :success => true) #success 参数 判断用户同步成功 
    rescue Exception => e
      Rails.logger.error(e)
      notice_stickie t("notice.oauth.ouath_failure")
      redirect_to setting_sns_friends_path(:sns_name => params[:type], :failure => true)# failure 参数判定用户同步失败
    end
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
      id = no_need_user_ids(ids) #去掉 current_user
      return ids.join(",") #转化为字符串
    end
  end
  
  #去掉自己和已关注的人的id
  def no_need_user_ids(ids)
    following_ids = current_user.followings.pluck(:id) 
    following_ids << current_user.id
    ids - following_ids
  end
end
