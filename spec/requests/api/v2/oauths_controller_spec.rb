# encoding: utf-8
require 'spec_helper'
describe Api::V2::OauthsController do
  context "user had oauth item" do
    #let(:user_oauth) = { Factory(:user_oauth) }
    before(:each) do

      #post api_sessions_path,
      #  {:user => {:email => 'gxbsst@gmail.com', :password => '51448888'}},
      #  {'Accept' => 'application/vnd.iwine.com; version=1'}
      #@response = response
      #@parsed_body = JSON.parse(@response.body)
      #binding.pry
      @token = User.find(2).authentication_token
    end

    describe "#binding" do
      it "should bind success" do
        #{:oauth_user => {:sns_user_id => "....", :sns_name => "weibo", :access_token => ""}}
        post bind_api_oauths_path,
             {:oauth_user => {
                 :sns_name => 'weibo',
                 :sns_user_id => '1111',
                 :provider_user_id => '1111',
                 :setting_type => 2,
                 :access_token => "access_token...."
             }, :auth_token => @token
             },
             {'Accept' => 'application/vnd.iwine.com; version=2'}
            @response = response
            @response.status.should be(200)
            @parsed_body = JSON.parse(@response.body)
        binding.pry
        @parsed_body['success'].should == 1
        @parsed_body['data'].should include("weibo")
      end
    end


    describe "#unbinding" do
      it "should unbind success" do
        #{:oauth_user => {:sns_user_id => "....", :sns_name => "weibo", :access_token => ""}}
        post unbind_api_oauths_path,
             {:sns_name => 'weibo',
              :auth_token => @token
             },
             {'Accept' => 'application/vnd.iwine.com; version=2'}
        @response = response
        @response.status.should be(200)
        @parsed_body = JSON.parse(@response.body)
        binding.pry
        @parsed_body['success'].should == 1
        @parsed_body['data'].should include("weibo")
      end
    end


  end

end


