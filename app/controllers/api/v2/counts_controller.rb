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
        resource = {}
        voter = User.find(params[:user_id])
        params[:ids].split(",").each do |id|
          resource[id] = {}
          countable = build_coutable(id)
          is_liked = ::Service::VoteService.is_liked? voter, countable
          counter = Service::CountService::Count.call(countable)
          resource[id][:likes] = counter.likes
          resource[id][:comments] = counter.comments
          resource[id][:is_liked] = is_liked
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
        countable = Note.new
        countable.id = id
        countable
      end

    end

  end
end
