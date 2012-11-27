require 'spec_helper'

describe Api::V2::PasswordsController do
  context "params is no correct" do
    before(:each) do
      post api_passwords_path,
           {:user => {:email => 'aaa@gmail.com'}},
           {'Accept' => 'application/vnd.iwine.com; version=2'}
      @response = response
      @result = JSON.parse(@response.body)
    end

    it { @result["success"].should == 0}
    it { @result["resultCode"].should == 431}

  end

  context "params is correct" do
    before(:each) do
      post api_passwords_path,
           {:user => {:email => 'gxbsst@gmail.com'}},
           {'Accept' => 'application/vnd.iwine.com; version=2'}
      @response = response
      @result = JSON.parse(@response.body)
    end

    it { @result["success"].should == 1}
    it { @result["resultCode"].should == 200}


  end

end

