# encoding: utf-8
class FilelessIO < StringIO
    attr_accessor :original_filename
end

module Api
  module V1
    class UploadsController < ::Api::BaseApiController
      before_filter :parse_xml
      before_filter :get_token
      before_filter :authenticate_user!

      def create
        io = FilelessIO.new(Base64.decode64(@encoded_img))
        io.original_filename = "avatar.png"
        current_user.avatar = io
        if current_user.save
          render :json => build_json(current_user)
        else
          invalid_json
        end
      end

      protected

      def parse_xml
        doc = Nokogiri::XML(request.body.read)  
        doc.xpath("//MediaObject").text =~  /^<\!\[CDATA\[(.+)\]\]>$/
        @encoded_img = $1 
        @auth_token = doc.xpath("//AuthToken").text 
      end

      def get_token
        params[:auth_token] = @auth_token 
      end

      def invalid_json
       render :json => {:success => false }
      end

      def build_json(user)
        return {:success => true, 
          :avatar => user.avatar.url(:large)}
      end

    end
  end
end