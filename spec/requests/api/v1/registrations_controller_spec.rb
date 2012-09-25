require 'spec_helper'
describe Api::V1::RegistrationsController do
  it "should get confirmation_token" do
    post api_registrations_path, 
         {:user => {:email => "522226222523129222299@gmail.com", 
                    :username => "5265222222231222222999",
                    :password => "514428888", 
                    :agree_term => 1}}, 
         {'Accept' => 'application/vnd.iwine.com; version=1'}

    @response = response
    @parsed_body = JSON.parse(@response.body)
    @token = @parsed_body["user"]['confirmation_token']
    @token.should_not be_nil
  end

end
