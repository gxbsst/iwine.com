# encoding: utf-8
require 'spec_helper'

describe SearchesController do
 before(:each) do
   get "searches/wine.json", :word=> "Baron de Milon"
   @response = response
   @parsed_body = JSON.parse(@response.body)
 end

 it "item size should > 1" do
    @parsed_body.size.should be(1) 
 end

 it "should include  wine Baron de Milon" do
   #@response.body.should include("Baron de Milon") 
   @parsed_body.should == "Baron de Milon"
 end
 
end

