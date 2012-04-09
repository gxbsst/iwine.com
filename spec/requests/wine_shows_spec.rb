# -*- coding: utf-8 -*-
require 'spec_helper'

describe "WineShows" do
  describe "GET /wine_shows" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      # get wine_shows_path
      # get "/wines"
      visit "/wines"
      page.should have_content("关于我们")
      click_link "test2"

      # response.status.should be(200)
      # response.body.should include("关于我们")
    end
  end

  # describe "GET /wine_shows" do
  #   it "works! (now write some real specs)" do
  #     # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
  #     # get wine_shows_path
  #     # get "/wines"
  #     # response.status.should be(200)
  #     # response.body.should include("关于我们")
  #   end

  it "rediret_to" do
    get "/mine"
    response.should redirect_to('/users/sign_in')
  end

  it "support js", :js => true do
    visit "/wines"
    # click_link "test"
    page.should have_content("js works")
  end
end

