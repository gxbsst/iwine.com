require 'spec_helper'

describe Api::V1::SessionsController do
  before(:each) do
    post api_sessions_path, 
         {:user => {:email => 'gxbsst@gmail.com', :password => '51448888'}},
         {'Accept' => 'application/vnd.iwine.com; version=1'}
    @response = response
  end
 
  it "should auth success" do
    @response.status.should be(200)
    @response.body.should include("success") 
  end
  
  it "should get login emai"  do
    parsed_body = JSON.parse(@response.body)
    parsed_body["user"]["email"].should == "gxbsst@gmail.com"
  end

  it "should get private resource when login success" do
     parsed_body = JSON.parse(@response.body)
     token = parsed_body["user"]['auth_token']
     get basic_settings_path, :auth_token => token
     response.status.should be(200)
     response.body.should include("city")
  end
end

