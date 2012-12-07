# encoding: utf-8
module Api
  module V2
    class FriendsController < Api::BaseApiController
      #   返回
      #1. 关注数／被关注数
      #2. 关注状态（是否为互相关注）
      #3. 被关注的用户信息
      #4. 被关注的人的藏酒
      #5. 在user表添加notes_count, 给kim使用
      #6. 排名
      #7. 勋章

      before_filter :authenticate_user!
      before_filter :get_user

      def index
        resource = Service::FriendService::Recommend.call(@user, params[:sns_name])
        resource.delete_if{|user| @user.is_following user.id}
        status = resource.present? ? true : false
        render :json => ::Api::Helpers::FriendJsonSerializer.as_json(resource, status)
        # 推荐的好友， 即微博好友已经在网站登陆但是未被关注的
        #resource = @user.recommends(params[:ids])
        #render :json => ::Api::Helpers::FriendJsonSerializer.as_json(resource, true)
      end

      def create
        # follow
        if params[:user][:id].present?
          resource = User.find(params[:user][:id])
          render :json => ::Api::Helpers::FriendJsonSerializer.as_json(resource, @user.follow_user(resource.id))
        else
          render :json => 'id不能为空'
        end
      end

      def destroy
        # unfollow
        if params[:id].present?
          resource = User.find(params[:id])
          render :json => ::Api::Helpers::FriendJsonSerializer.as_json(resource,
                                                                       @user.unfollow(resource))
        else
          render :json => 'id不能为空'
        end
      end

      protected

      def get_user
        @user ||= current_user
      end

    end
  end
end