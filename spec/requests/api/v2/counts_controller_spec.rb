require 'spec_helper'

describe Api::V2::CountsController do
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
      get notes_api_counts_path,
          {:ids => '1,2,3', :user_id => 2},
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
