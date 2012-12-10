#encoding: utf-8
module Api
  module V2
    class FollowsController < ::Api::BaseApiController
      before_filter :authenticate_user!, :except => [:index]
      before_filter :get_user

      def index
        #params: commentable_id & commentable_type
        resource = NoteFollow.where(:followable_id => params[:followable_id], :followable_type => params[:followable_type])
        status  = resource.present? ? true : false
        render :json => ::Api::Helpers::FollowJsonSerializer.as_json(resource, status)
      end

      def create
        #params[:notes_comment] user_id commentable_id commentable_type body
        params[:notes_follow][:user_id] = @user.id
        resource = NoteFollow.where(:user_id => @user.id, :followable_id => params[:notes_follow][:followable_id], :followable_type => params[:notes_follow][:followable_type]).first || NoteFollow.new(params[:notes_follow])
        status  =  resource.valid? ? true : false
        render :json => ::Api::Helpers::FollowJsonSerializer.as_json(resource.save, status)
      end

      protected

      def get_user
        @user ||= current_user
      end

    end
  end
end
