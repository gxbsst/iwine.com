require 'spec_helper'
describe Api::V1::RegistrationsController do
  it "should get v1" do
    post api_registrations_path, 
         {:user => {:email => "5265231999@gmail.com", 
                    :username => "5652231999",
                    :password => "514428888", 
                    :agree_term => 1}}, 
         {'Accept' => 'application/vnd.iwine.com; version=1'}
    response.status.should be(201)
    response.body.should include("success") 
  end
end
