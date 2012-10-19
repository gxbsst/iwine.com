# encoding: utf-8
require 'spec_helper'
describe Api::V1::ConfirmationsController do
  before(:each) do
    post api_registrations_path, 
      {:user => {:email => "5265231999@22gmail.com",
        :username => "565223199229",
        :password => "514428888", 
        :agree_term => 1
    }},
      {'Accept' => 'application/vnd.iwine.com; version=1'}
    @response = response
    @parsed_body = JSON.parse(@response.body)
    @token = @parsed_body["user"]['confirmation_token']
  end

  it 'shoud return error desc 201' do
    get api_confirmations_path(), {:confirmation_token => @token}, {'Accept' => 'application/vnd.iwine.com; version=1'}
    @response = response
    @parsed_body = JSON.parse(@response.body)
    @parsed_body.should include('200')

  end
end
