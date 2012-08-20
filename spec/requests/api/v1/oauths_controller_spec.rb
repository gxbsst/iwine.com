# encoding: utf-8
require 'spec_helper'
describe Api::V1::OauthsController do
  context "user had oauth item" do
    #let(:user_oauth) = { Factory(:user_oauth) }
    before(:each) do
      #@user = User.find_by_email('gxbsst@gmail.com')
      #@user_oauth =  @user.oauths.build({:sns_name => 'sina', :sns_user_id => '1111', :nickname => 'weixuhong'})
      #@user_oauth.save
      #post api_sessions_path, 
        #{:user => {:email => 'gxbsst@gmail.com', :password => '51448888'}},
        #{'Accept' => 'application/vnd.iwine.com; version=1'}
      #@response = response
      #@parsed_body = JSON.parse(@response.body)
      #@token = @parsed_body["user"]['auth_token']
    end

    describe "#create" do
      it "should auth success" do
        post api_oauths_path, 
          {:oauth_user => {
            :sns_name => 'sina', 
            :nickname => 'weixuhongabc_dd',
            :sns_user_id => '1111'}
            },
            {'Accept' => 'application/vnd.iwine.com; version=1'}
        #@response.status.should be(200)
        #@response.body.should include("gxbsst") 
            @response = response
            @response.status.should be(200)
            @parsed_body = JSON.parse(@response.body)
            @parsed_body['user']['email'].should eql("1111sina@iwine.com")
            User.find_by_email( @parsed_body['user']['email'] ).confirmed_at.should_not be_nil
      end
    end

  end

  context "user don't have user_oauth item" do
  
    before(:each) do
      #@user = User.find_by_email('gxbsst@gmail.com')
      #post api_sessions_path, 
        #{:user => {:email => 'gxbsst@gmail.com', :password => '51448888'}},
        #{'Accept' => 'application/vnd.iwine.com; version=1'}
      #@response = response
      #@parsed_body = JSON.parse(@response.body)
      #@token = @parsed_body["user"]['auth_token']
    end

    
    describe "#create" do
      it "should auth success" do
        post api_oauths_path, 
          {:oauth_user => { 
            :sns_name => 'qq', 
            :nickname => 'weixuhong_backdd',
            :sns_user_id => '1111'}
            },
            {'Accept' => 'application/vnd.iwine.com; version=1'}
        #@response.status.should be(200)
        #@response.body.should include("gxbsst") 
       #item = @user.oauths.login_provider("qq")
        #item.should be_present
        #item.first.nickname.should eql("weixuhong")
            @response = response
            @parsed_body = JSON.parse(@response.body)
            @parsed_body['user']['username'].should eql("weixuhong_backdd")
      end

    end
  
  end
end


