require 'spec_helper'
describe SettingsController  do

  describe "#domain" do
    it "should recognize a routes" do
     domain_settings_path.should eql "/settings/domain" 
    end

    it "returns http success" do
      visit 'domain'
      response.should be_success
    end
  end  
  
end
