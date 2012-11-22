# encoding: utf-8
module Notes
  class NoteAgent
    # Default options while posting an ERP request
    DEFAULT_OPTIONS = {
        :host => 'iwinenotes.iwine.com',
        :port => '8080',
        :path => '',
        :content_type => "application/text; charset=utf-8;",
        :body => ""
    }

    # Return an available http client
    def self.get_http_client(host, port, use_ssl = false)
      http = Net::HTTP.new(host, port)
      if use_ssl
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
      return http
    end

    # Post request to WebService
    # params:
    #  service_url
    def self.post(options)
      options = DEFAULT_OPTIONS.merge options
      http = get_http_client(options[:host], options[:port])
      # # Setting up an Post
      request = Net::HTTP::Post.new options[:path]
      request.set_form_data(options[:body])
      #request.set_content_type options[:content_type] unless options[:content_type].blank?
      # Posting
      # TODO:
      #   1. Exception Handler
      begin
        response = http.request(request)
      rescue => e
        Rails.logger.info(e)
      ensure
        # do something
      end
      response
    end

    def self.get(options)
      options = DEFAULT_OPTIONS.merge options
      http = get_http_client(options[:host], options[:port])
      request = Net::HTTP::Get.new options[:path]
      begin
        response = http.request(request)
      rescue => e
        # do something
        Rails.logger.info(e)
      ensure
        # do something
      end
      response
    end
  end
end