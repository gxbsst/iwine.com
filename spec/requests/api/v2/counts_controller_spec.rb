require 'spec_helper'

describe Api::V2::CountsController do

  before(:each) do
    post api_sessions_path,
         {:user => {:email => 'gxbsst@gmail.com', :password => 'wxh51448888'}},
         {'Accept' => 'application/vnd.iwine.com; version=2'}
    @user = User.find_by_email('gxbsst@gmail.com')
    @response = response
    @parsed_body = JSON.parse(@response.body)
    @token = @parsed_body["user"]['auth_token']
  end

  describe "#index" do
    before(:each) do
      get api_counts_path,
          {:countable_type => 'Note', :countable_id => 1},
          {'Accept' => 'application/vnd.iwine.com; version=2'}
      @response = response
      @parsed_body = JSON.parse(@response.body)
    end

    it { @parsed_body["success"].should == 1}
    it { @parsed_body["resultCode"].should == 200}
    it { @parsed_body['data'].should include("likes_count") }
    it { @parsed_body['data'].should include("comments_count") }
  end

  describe "#notes" do
    before(:each) do
      post api_comments_path,
           {:notes_comment => {:commentable_id => 10, :commentable_type => 'Note', :body => "here is comment body"}, :auth_token => @token},
           {'Accept' => 'application/vnd.iwine.com; version=2'}
      post api_votes_path,
           {:id => 1, :votable_type => 'Note', :auth_token => @token},
           {'Accept' => 'application/vnd.iwine.com; version=2'}

      get notes_api_counts_path,
          {:ids => '1,2,10', :user_id => 2},
          {'Accept' => 'application/vnd.iwine.com; version=2'}
      @response = response
      @parsed_body = JSON.parse(@response.body)
    end

    it { @parsed_body["success"].should == 1}
    it { @parsed_body["resultCode"].should == 200}
    it { @parsed_body['data'].should include("likes_count") }
    it { @parsed_body['data'].should include("comments_count") }
  end


end
