require 'spec_helper'

describe Api::RegionsController do
 before(:each) do
   get '/api/regions/region_tree', :query => "Wuwei"
   @response = response
 end

 it "item size should > 1" do
    parsed_body = JSON.parse(@response.body)
    parsed_body.size.should < 0
 end

 it "should include a lot regions" do
   @response.body.should include("Rosstal") 
 end
end
