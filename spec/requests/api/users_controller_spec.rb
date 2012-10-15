require 'spec_helper'

describe Api::UsersController do
  before(:each) do
      post api_sessions_path, 
        {:user => {:email => 'gxbsst@gmail.com', :password => '51448888'}},
        {'Accept' => 'application/vnd.iwine.com; version=1'}
      @response = response
      @parsed_body = JSON.parse(@response.body)
      @token = @parsed_body["user"]['auth_token']
      @user_id = @parsed_body["user"]['id']
  end

  it "should response user's all friends" do
    get "/api/users/friends"
    @response = response
    @parsed_body = JSON.parse(@response.body)
    @parsed_body.size.should > 0
  end

end
