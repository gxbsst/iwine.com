require 'spec_helper'

describe Api::V2::VotesController do

  before(:each) do
    post api_sessions_path,
         {:user => {:email => 'gxbsst@gmail.com', :password => 'wxh51448888'}},
         {'Accept' => 'application/vnd.iwine.com; version=2'}
    @user = User.find_by_email('gxbsst@gmail.com')
    @response = response
    @parsed_body = JSON.parse(@response.body)
    @token = @parsed_body["user"]['auth_token']
  end

  describe 'note vote' do
    context "comment is success" do
      before(:each) do
        post api_votes_path,
             {:id => 1, :votable_type => 'Note', :auth_token => @token},
             {'Accept' => 'application/vnd.iwine.com; version=2'}
        @response = response
        @result = JSON.parse(@response.body)


      end

      it { @result["success"].should == 1}
      it { @result["resultCode"].should == 200}
    end
  end

  describe 'note un vote' do
    context "un vote is success" do
      before(:each) do

        post api_votes_path,
             {:id => 1, :votable_type => 'Note', :auth_token => @token},
             {'Accept' => 'application/vnd.iwine.com; version=2'}

        votable = Note.new
        votable.id = 1
        delete '/api/votes/1',
             {:votable_type => 'Note', :auth_token => @token},
             {'Accept' => 'application/vnd.iwine.com; version=2'}
        @response = response
        @result = JSON.parse(@response.body)


      end

      it { @result["success"].should == 1}
      it { @result["resultCode"].should == 200}
    end
  end


end
