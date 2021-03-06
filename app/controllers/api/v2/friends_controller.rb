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

      # 这里主要是为了给user添加一个followed 字段，判断用户是否被关注
      ::User.class_eval do
        attr_accessor :followed

        def followed
          @follow
        end

        def followed=(follow_status=false)
          @follow = follow_status
        end

        def as_json(options = { })
          h = super(options)
          h[:followed]   = followed
          h
        end

      end

      before_filter :authenticate_user!
      before_filter :get_user

      def index
        resource = Service::FriendService::Recommend.call_with_classify(@user, params[:sns_name])
        %w(sina douban tencent).each do  |key|
          resource[key].uniq!
          if resource[key].present?
            resource[key].each{|user| (@user.is_following user.id) ? user.followed = true : user.followed = false}
            #.delete_if{ |user| @user.is_following user.id }
          end
        end
        #status = resource.present? ? true : false
        render :json => ::Api::Helpers::FriendJsonSerializer.as_json(resource, true)
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

      # 获取朋友关系状态
      def state
        user_b = User.find(params[:user_id])
        resource = Service::FriendService::State.run(@user, user_b)
        render :json => ::Api::Helpers::FriendJsonSerializer.as_json(resource, true)
      end

      # invite
      def invite
        Service::MailerService::Mailer.deliver(FriendMailer, :invite, params)
        render :json => ::Api::Helpers::FriendJsonSerializer.as_json(true, true)
      end

      protected

      def get_user
        @user ||= current_user
      end

    end
  end
end