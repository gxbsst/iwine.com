# encoding: utf-8
module Api
  module V2
    class ReportsController < ::Api::BaseApiController
      #before_filter :authenticate_user!, :except => [:create]
      before_filter :get_user

      def create
        options = {
            :subject => "Note Report",
            :description => params[:note_id],
            :email => @user.email
        }

        resource = Service::ReportService::NoteReport.process(options)
        status = resource.errors.any? ? true : false
        render :json => ::Api::Helpers::ReportJsonSerializer.as_json(resource, status)
      end

      protected

      def get_user
        @user ||= User.find(2)
      end

    end
  end
end
