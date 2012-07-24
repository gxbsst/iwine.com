require 'spec_helper'

describe FollowsController do
  it "returns http success" do
    visit 'new'
    response.should be_success
  end
end
