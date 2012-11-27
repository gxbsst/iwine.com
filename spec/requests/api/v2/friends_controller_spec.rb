require 'spec_helper'

describe Api::V2::FriendsController do

  before(:each) do
    post api_sessions_path,
         {:user => {:email => 'gxbsst@gmail.com', :password => 'wxh51448888'}},
         {'Accept' => 'application/vnd.iwine.com; version=2'}
    @user = User.find_by_email('gxbsst@gmail.com')
    @be_follower = create(:user)
    @response = response
    @parsed_body = JSON.parse(@response.body)
    @token = @parsed_body["user"]['auth_token']
  end

  describe 'follow user' do
    context "follow is success" do
      before(:each) do
        post api_friends_path,
             {:user => {:id => @be_follower.id}, :auth_token => @token},
             {'Accept' => 'application/vnd.iwine.com; version=2'}
        @response = response
        @result = JSON.parse(@response.body)
      end

      it { @result["success"].should == 1}
      it { @result["resultCode"].should == 200}
    end

    context "follow is failed" do
      before(:each) do
        post api_friends_path,
             {:user => {:id => @user.id}, :auth_token => @token},
             {'Accept' => 'application/vnd.iwine.com; version=2'}
        @response = response
        @result = JSON.parse(@response.body)
      end

      it { @result["success"].should == 0}
      it { @result["resultCode"].should == 431}
    end
  end


  describe 'unfollow user' do
    context "unfollow is success" do
      before(:each) do
        post api_friends_path,
             {:user => {:id => @be_follower.id}, :auth_token => @token},
             {'Accept' => 'application/vnd.iwine.com; version=2'}

        delete api_friend_path(@be_follower),
               {:auth_token => @token},
               {'Accept' => 'application/vnd.iwine.com; version=2'}
        @response = response
        @result = JSON.parse(@response.body)
      end

      it { @result["success"].should == 1}
      it { @result["resultCode"].should == 200}

    end

    context "unfollow is failed" do
      before(:each) do
        delete api_friend_path(@be_follower),
               {:auth_token => @token},
               {'Accept' => 'application/vnd.iwine.com; version=2'}
        @response = response
        @result = JSON.parse(@response.body)
      end

      it { @result["success"].should == 0}
      it { @result["resultCode"].should == 431}
      it {@response.body.should include("cellar_count")}

    end

  end

end
