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
                 :profile_attributes => {:phone_number => "13333", :birthday => Date.parse('2002-12-03'), :bio => "未。。。"}}, 
                 :auth_token => @token},
      {'Accept' => 'application/vnd.iwine.com; version=1'}
    @response.status.should be(200)
    @response.body.should include("success") 
  end

  it "update should success and username should include hellokitty" do
       put api_profile_path(@user.profile), 
      {:user => {:city => "shanghai", 
                 :username => "hellokitty", 
                 :profile_attributes => {:phone_number => "13333", :birthday => Date.parse('2002-12-03'), :bio => "未。。。"}}, 
                 :auth_token => @token},
      {'Accept' => 'application/vnd.iwine.com; version=1'}
       @response.body.should include("hellokitty")
  end

  describe "#birthday" do 
    it "birthday shoud be 2002-12-03" do
      @user = User.find_by_email("gxbsst@gmail.com")
      @user.profile.birthday.should == Date.parse('2002-12-02')
    end  
  end

  describe "#phone_number" do 
    it "phone_number shoud be 133333" do
      @user = User.find_by_email("gxbsst@gmail.com")
      @user.profile.phone_number.should  eql("13333") 
    end  
  end

  describe "#index" do
   it "shoud get user profile info" do
    get api_profiles_path, {:auth_token => @token},  {'Accept' => 'application/vnd.iwine.com; version=1'}
    response.body.should include("gxbsst")
   end  
  end

  describe "#show" do
    before(:each) do
      get api_profile_path(@user), '',  {'Accept' => 'application/vnd.iwine.com; version=1'}
      @response = response
      @parsed_body = JSON.parse(@response.body)
    end
    it "result should be a hash" do
      @parsed_body.keys.should include('user')
    end  
    it 'shoud get usename' do
      @parsed_body['user']['username'].should include('hello') 
    end
    it 'email should be blank' do
      @parsed_body['user']['email'].should  be_blank 
    end
  end
end


