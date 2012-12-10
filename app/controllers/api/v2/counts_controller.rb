#encoding: utf-8
module Api
  module V2
    class CountsController < ::Api::BaseApiController

      before_filter :get_countable

      def index
        resource = Service::CountService::Count.call(@countable)
        status = @countable ? true : false
        render :json => ::Api::Helpers::CountJsonSerializer.as_json(resource, status)
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
    end

  end
end
