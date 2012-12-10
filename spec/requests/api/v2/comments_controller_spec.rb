require 'spec_helper'

describe Api::V2::CommentsController do

  before(:each) do
    post api_sessions_path,
         {:user => {:email => 'gxbsst@gmail.com', :password => 'wxh51448888'}},
         {'Accept' => 'application/vnd.iwine.com; version=2'}
    @user = User.find_by_email('gxbsst@gmail.com')
    @response = response
    @parsed_body = JSON.parse(@response.body)
    @token = @parsed_body["user"]['auth_token']
  end

  describe 'note comment' do
    context "comment is success" do
      before(:each) do
        post api_comments_path,
             {:notes_comment => {:commentable_id => 10, :commentable_type => 'Note', :body => "here is comment body"}, :auth_token => @token},
             {'Accept' => 'application/vnd.iwine.com; version=2'}
        @response = response
        @result = JSON.parse(@response.body)
      end

      it { @result["success"].should == 1}
      it { @result["resultCode"].should == 2000}
    end


    context "get comment list" do
      before(:each) do
        get api_comments_path,
             {:commentable_type => 'Note', :commentable_id => 1, :auth_token => @token},
             {'Accept' => 'application/vnd.iwine.com; version=2'}
        @response = response
        @result = JSON.parse(@response.body)
      end

      it { @result["success"].should == 1}
      it { @result["resultCode"].should == 2000}
    end

  end
end
