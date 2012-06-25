require 'spec_helper'
describe Winery do

  describe "#wines_count" do
    before(:each) do
      @wine_detail = create(:wine_detail)
      @winery = @wine_detail.wine.winery
    end
    it "should increment if create" do
      Winery.find(@winery).wines_count.should be(1)
    end

    it "should decrement if destroy" do
      @wine_detail.destroy
      Winery.find(@winery).wines_count.should be(0)
    end

  end
end
