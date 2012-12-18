#encoding: utf-8
module Api
  module V2
    class CountsController < ::Api::BaseApiController

      before_filter :get_countable, :except => [:notes]

      def index
        resource = Service::CountService::Count.call(@countable)
        status = @countable ? true : false
        render :json => ::Api::Helpers::CountJsonSerializer.as_json(resource, status)
      end

      def notes #For Note
        resource = []
        begin
          voter = User.find(params[:user_id])
          liked = ::Service::VoteService.is_liked? voter, countable
        rescue ActiveRecord::RecordNotFound
          liked = false
        end
        params[:ids].split(",").each do |id|
          countable = build_coutable(id)
          counter = Service::CountService::Count.call(countable)
          result = {:id => id, :likes => counter.likes, :comments => counter.comments, :liked => liked}
          resource << result
        end
        render :json => ::Api::Helpers::CountJsonSerializer.as_json(resource, true)
      end

      protected

      def get_countable
        @resource, @id = params[:countable_type], params[:countable_id]
        @resource = "Wines::Detail" if @resource == "wines"
        # Note 是虚拟的数据
        if @resource == 'Note'
          @countable = Note.new
          @countable.id = @id
          @countable.app_note_id = @id
        else
          @countable = @resource.singularize.classify.constantize.find(@id)
        end
        @countable
      end

      def build_coutable(id)
        Note.find_by_app_note_id(id) || Note.sync_note_base_app_note_id(id)
      end

    end

  end
end
