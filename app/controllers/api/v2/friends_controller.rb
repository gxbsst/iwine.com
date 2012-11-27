# encoding: utf-8
module Api
  module V2
    class FriendsController < ::Api::BaseApiController

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
        render :json => FriendJsonSerializer::FollowSerializer.as_json(resource)
      end

      def create
        # follow
        resource = User.find(params[:user][:id])
        render :json => FriendJsonSerializer::FollowSerializer.as_json(resource,  @user.follow_user(resource.id))
      end

      def destroy
        # unfollow
        resource = User.find(params[:id])
        render :json => FriendJsonSerializer::DestroySerializer.as_json(resource, @user.unfollow(resource))
      end

      protected

      def get_user
        @user ||= current_user
      end

    end
  end
end