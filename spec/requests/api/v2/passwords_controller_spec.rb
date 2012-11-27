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

  context "Test mock stub " do
    describe "A behaviour description" do
      it "has an example" do
        my_mock = mock(Object, :stub_method => 'return true')
        my_mock.stub_method.should == 'return false'
      end

      it 'has an example with message expectation ' do
        my_mock = mock(Object, :expected_method => 'value')
        my_mock.should_receive(:expected_methods)
        my_mock.expected_method
      end
    end
  end

end

