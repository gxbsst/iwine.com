#encoding: utf-8
module Api
  module V2
    class VotesController < ::Api::BaseApiController
      before_filter :authenticate_user!
      before_filter :get_user
      before_filter :get_votable

      def create
        # voteable_type & id
        status = Service::VoteService::Vote.run(@votable, @user)
        render :json => ::Api::Helpers::VoteJsonSerializer.as_json(@votable, status)
      end

      def destroy
        # voteable_type & id
        status = Service::VoteService::UnVote.run(@votable, @user)
        render :json => ::Api::Helpers::VoteJsonSerializer.as_json(@votable, status)
      end

      protected

      def get_user
        @user ||= current_user
      end

      def get_votable
        @resource, @id = params[:votable_type], params[:id]
        @resource = "Wines::Detail" if @resource == "wines"
        # Note 是虚拟的数据
        if @resource == 'Note'
          @votable = Note.new
          @votable.id = @id
          @votable.app_note_id = @id
          @votable
          #@votable = Note.sync_note_base_app_note_id(@id)
        else
          @votable = @resource.singularize.classify.constantize.find(@id)
        end
        @votable
      end

    end
  end
end