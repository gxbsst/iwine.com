# encoding: utf-8
class UsersController < ApplicationController
  before_filter :authenticate_user!, :only => [:follow, :unfollow]
  before_filter :get_user, :except => [:register_success]
  before_filter :get_recommend_users, :only => [:followings, :followers, :start]
  before_filter :get_cellar_items, :only => [:show]

  def show
    @followers = @user.followers
    @followings = @user.followings
    @comments = @user.comments.real_comments.limit(6)
    @following_wines = @user.wine_followings.limit(4)
  end

  # 关注的酒
  def wine_follows
    @title = ["关注的酒", @user.username].join("-")
    @follows = @user.wine_followings.order("created_at DESC").page(params[:page] || 1).per(10)
    @hot_wines = Wines::Detail.hot_wines(5)
  end

  # 关注的酒庄
  def winery_follows
    @title = ["关注的酒庄", @user.username].join("-")
    @follows = @user.winery_followings.order("created_at DESC").page(params[:page] || 1).per(10)
    @hot_wineries = Winery.hot_wineries(5)
  end
  
  def note_follows
    @title = ["收藏", @user.username].join("-")
    @follows = @user.note_followings.order("created_at DESC").page(params[:page] || 1).per(10) 
    # 热门品酒辞
    result      = Notes::NotesRepository.all 
    return render_404('') unless result['state']
    @notes = Notes::HelperMethods.build_all_notes(result)  
  end


  # 我的评论
  def comments
    @current_tab = params[:tab] || 'comment'
    @title = ["评论", @user.username].join("-")
    @hot_wines = Wines::Detail.hot_wines(5)
    @comments = @user.comments.real_comments.page(params[:page] || 1).per(10)
  end

  def notes 
    notes_result = Notes::NotesRepository.find_by_user(@user.id, '', '')
    return render_404('') unless notes_result['state']

    if @user == current_user
      @user_notes = Notes::HelperMethods.build_user_notes(notes_result, false)
    else
      @user_notes = Notes::HelperMethods.build_user_notes(notes_result)
    end
    #unless @user_notes.blank?
    #  if @user != current_user
    #     @user_notes = @user_notes.select {|user_note| user_note[:note].statusFlag.to_i <= 0}
    #  end
    #end

    @user_notes = Kaminari.paginate_array(@user_notes).page(params[:page] || 1).per(10)  

    #热门品酒辞
    result      = Notes::NotesRepository.all 
    return render_404('') unless result['state']
    @notes = Notes::HelperMethods.build_all_notes(result)  
  end

  def followings
    @title = ["关注的人", @user.username].join("-")
    @followings = @user.followings.page(params[:page] || 1).per(18)
    unless current_user == nil
      @recommend_users = @user.remove_followings_from_user User.all :conditions =>  "id <> "+ @user.id.to_s , :limit => 5
    end
  end

  def followers
    @title = ["粉丝", @user.username].join("-")
    @followers = @user.followers.page(params[:page] || 1).per(18)
    unless current_user == nil
       @recommend_users = @user.remove_followings_from_user User.all :conditions =>  "id <> "+ @user.id.to_s , :limit => 5
    end
   
  end

  # 用户第一次登录
  def start
    if current_user.sign_in_count == 1
      @hot_wines = Wines::Detail.hot_wines(12)
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

  def follow
    if current_user.is_following params[:id]  
      #重复关注某人 
       notice_stickie t("notice.friend.re_follow")
    end

    if current_user.slug == params[:id]
      #关注自己 
      #notice_stickie t("notice.friend.self_follow")
    else
        if params[:user_id].present?
          # 关注多个
          params[:user_id].split(',').each do |user_id|
            if current_user.id != user_id.to_i
              current_user.follow_user user_id
              # notice_stickie t("notice.friend.follow")
            end
          end
        else
          # 关注一个
          if current_user.follow_user params[:id]
            notice_stickie t("notice.friend.follow")
          end
        end
    end
    redirect_to request.referer || followings_user_path(current_user)
  end

  def unfollow
    if current_user.unfollow(@user)
      notice_stickie t("notice.friend.unfollow")
      redirect_to(followings_user_path(current_user))
    end
  end

  private
  def get_user
    @user ||= User.find(params[:id])
  end

  def get_recommend_users
    @recommend_users = User.no_self_recommends(5, @user.id)
  end

  def get_cellar_items
    if current_user && current_user == @user
      @cellar_items = @user.cellar.mine_items.limit(4)
    else
      @cellar_items = @user.cellar.user_items.limit(4)
    end
  end
end
