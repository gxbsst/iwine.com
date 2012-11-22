# encoding: utf-8
class FilelessIO < StringIO
    attr_accessor :original_filename
end

module Api
  module V2
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
        render :json => {:success => 0, 
          :resultCode => APP_DATA["api"]["return_json"]["normal_failed"]["code"],
          :errorDesc => APP_DATA["api"]["return_json"]["normal_failed"]["message"]
          #:message => object.errors.messages
        }
      end

      def build_json(user)
        return {:success => 1, 
          :resultCode => APP_DATA["api"]["return_json"]["normal_success"]["code"],
          :errorDesc => APP_DATA["api"]["return_json"]["normal_success"]["message"],
          :avatar => user.avatar.url(:large) + "?t=#{user.updated_at.to_i}"}
      end

    end
  end
end
