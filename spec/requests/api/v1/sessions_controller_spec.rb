require 'spec_helper'

describe Api::V1::SessionsController do
  context "params is correct" do
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

  context "params is missing" do
    before(:each) do
      post api_sessions_path, 
        {:user => nil},
        {'Accept' => 'application/vnd.iwine.com; version=1'}
      @response = response
    end
 
    it "http status should be 422" do
     @response.status.should be(422)
    end

    it "response should include erro" do
      @response.body.should include("miss")
    end
  end

  context "email and password is wrong" do
    before(:each) do
      post api_sessions_path, 
        {:user => {:email => 'www@gmail.com', :password => '514488'}},
        {'Accept' => 'application/vnd.iwine.com; version=1'}
      @response = response
    end

    it "http status should be 401" do
     @response.status.should be(401)
    end

    it "response should include erro" do
      @response.body.should include("Error")
    end
  
  end

end

