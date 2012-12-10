#encoding: utf-8
module Api
  module V2
    class CommentsController < ::Api::BaseApiController
      before_filter :authenticate_user!, :except => [:index]
      before_filter :get_user

      def index
        #params: commentable_id & commentable_type
        resource = NoteComment.includes(:user).where(:commentable_id => params[:commentable_id], :commentable_type => params[:commentable_type])
        status  = resource.present? ? true : false

        render :json => ::Api::Helpers::CommentJsonSerializer.as_json(resource, status)
      end

      def create
        #params[:notes_comment] commentable_id commentable_type body  & auth_token
        resource = NoteComment.new(params[:notes_comment])
        resource.user_id = @user.id
        status  =  resource.valid? ? true : false
        render :json => ::Api::Helpers::CommentJsonSerializer.as_json(resource.save, status)
      end

      protected

      def get_user
        @user ||= current_user
      end

    end
  end
end