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
      it { @result["resultCode"].should == 441}

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
      it { @result["resultCode"].should == 441}
    end

  end

  describe 'recommend friends' do
    before(:each) do
      @user = User.find_by_email('gxbsst@gmail.com')
      @sns_name = 'sina'
      get api_friends_path,
          {:sns_name => @sns_name, :auth_token => @token},
          {'Accept' => 'application/vnd.iwine.com; version=2'}
      @response = response
      @result = JSON.parse(@response.body)
    end

    it 'should return some friends' do

      @result['data'].count.should >  0
      @result['success'].should == 1

    end

  end

end
