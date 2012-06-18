require 'carrierwave/test/matchers'
require 'spec_helper'
require File.dirname(__FILE__) + '/../spec_helper'

describe ImageUploader do
  include CarrierWave::Test::Matchers
  let(:user) { Factory(:user) }
  before(:each) do
    ImageUploader.enable_processing = true  
    @file = File.open("/Users/weston/Desktop/winery_img.png")
  end

  describe Photo, "Wine" do
    before(:each) do
      @wine_detail = create(:wine_detail)
      @new_photo = @wine_detail.photos.build
      @new_photo.image = @file
    end

    it "photos_count should not be incremment " do
    	expect {
    		@new_photo.save!
    		}.to change{@wine_detail.photos_count}.by(0)

    end

    it "photos_count should  be incremment " do
    	@new_photo.save!
    	
    end
  end

  describe Photo, "Winery" do

  end

  describe Photo, " Album" do

  end

  describe Photo, "Comment" do

  end

end
