require 'spec_helper'
#require 'net/http'
#require "uri"
#require 'httparty'
describe Api::V1::UploadsController do
  before(:each) do
    #url = URI.parse('http://localhost:3000/api/uploads/')
    #HTTParty.post(api_uploads_path, :query => {:userID => 1024}, :body => xml )
    @file =File.read('/Users/weston/Projects/Patrick/spec/fixtures/files/image_upload.xml')
    #response = Net::HTTP::Post.new(url_path)
    #request.content_type = 'application/xml'
    #request.body = @file
    #request.header =  {'Accept' => 'application/vnd.iwine.com; version=1'}
    #response = Net::HTTP.start(url.host, url.port) {|http| http.request(request) } 
    #response = Net::HTTP::Post.new(url.path)
    
    #post api_sessions_path, 
        #{:user => {:email => 'gxbsst@gmail.com', :password => '51448888'}},
        #{'Accept' => 'application/vnd.iwine.com; version=1'}
      #@response = response
      #@parsed_body = JSON.parse(@response.body)
      #@token = @parsed_body["user"]['auth_token']
      #@file = File.open('/Users/weston/Projects/Patrick/file')
  end

  it "should auth success" do
    #post api_uploads_path, 
      #{:file => @file, :auth_token => @token},
      #{'Accept' => 'application/vnd.iwine.com; version=1'}
    #@response.body.should include("weixuhong") 
    pending
  end

end


