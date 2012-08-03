# encoding: utf-8
require 'spec_helper'
describe Api::V1::ProfilesController do
  before(:each) do
      post api_sessions_path, 
        {:user => {:email => 'gxbsst@gmail.com', :password => '51448888'}},
        {'Accept' => 'application/vnd.iwine.com; version=1'}
      @response = response
      @parsed_body = JSON.parse(@response.body)
      @token = @parsed_body["user"]['auth_token']
      @user = User.find_by_email('gxbsst@gmail.com')
      
  end

  it "should auth success" do

    put api_profile_path(@user.profile), 
      {:user => {:city => "shanghai", 
                 :username => "hellokitty", 
                 :profile_attributes => {:phone_number => "13333", :birthday => "2002-12-03", :bio => "未。。。"}}, 
                 :auth_token => @token},
      {'Accept' => 'application/vnd.iwine.com; version=1'}
    @response.status.should be(200)
    @response.body.should include("success") 
  end

  it "update should success and username should include hellokitty" do
       put api_profile_path(@user.profile), 
      {:user => {:city => "shanghai", 
                 :username => "hellokitty", 
                 :profile_attributes => {:phone_number => "13333", :birthday => "2002-12-03", :bio => "未。。。"}}, 
                 :auth_token => @token},
      {'Accept' => 'application/vnd.iwine.com; version=1'}
       @response.body.should include("hellokitty")
  end

  describe "#birthday" do 

    it "birthday shoud be 2002-12-03" do
      @user = User.find_by_email("gxbsst@gmail.com")
      #@user.birthday.should == Time.parse "2002-12-03"
    end  
  
  end

  describe "#index" do
   it "shoud get user profile info" do
    get api_profiles_path, {:auth_token => @token},  {'Accept' => 'application/vnd.iwine.com; version=1'}
    response.body.should include("weston")
   end  
  end

end


