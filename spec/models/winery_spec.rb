require 'spec_helper'
describe Winery do

  describe "#wines_count" do
    before(:each) do
      @wine = create(:wine)
      @winery = @wine.winery
    end
    it "should increment if create" do
      Winery.find(@winery).wines_count.should be(1)
    end

    it "should decrement if destroy" do
      @wine.destroy
      Winery.find(@winery).wines_count.should be(0)
    end

  end
end
