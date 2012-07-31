# encoding: utf-8
require 'spec_helper'
describe Api::V1::OauthsController do
  before(:each) do
      post api_sessions_path, 
        {:user => {:email => 'gxbsst@gmail.com', :password => '51448888'}},
        {'Accept' => 'application/vnd.iwine.com; version=1'}
      @response = response
      @parsed_body = JSON.parse(@response.body)
      @token = @parsed_body["user"]['auth_token']
      @user = User.find_by_email('gxbsst@gmail.com')
  end

  describe "#create" do
    it "should auth success" do
      post api_oauth_path, 
        {:oauth_user => {:user_id=> @user.id, 
          :sns_name => 'sina', 
          :sns_id => '12334234234234'}, 
          :auth_token => @token},
          {'Accept' => 'application/vnd.iwine.com; version=1'}
      @response.status.should be(200)
      @response.body.should include("success") 
    end
  end

end


