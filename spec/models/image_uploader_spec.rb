
require 'spec_helper'

# be_no_wider_than
# be_no_taller_than
# have_dimensions
# be_no_larger_than
# have_directory_permissions
# have_permissions
# be_identical_to

describe ImageUploader do
  include CarrierWave::Test::Matchers

  context "Imageable For All" do
    before do
      path_to_file = File.join(Rails.root, 'spec', 'support', 'rails.png')
      @photo = create(:photo)
      ImageUploader.enable_processing = true
      @uploader = ImageUploader.new(@photo, :image)
      # @uploader.should_process = true
      @uploader.store!(File.open(path_to_file))
    end

    after do
      ImageUploader.enable_processing = false
      @uploader.remove!
    end

    context 'the large_x version' do
      it "should scale down a landscape image to be exactly 610 by 640 pixels" do
        # @uploader.large_x.should have_dimensions(610, 640)
        @uploader.large_x.should be_no_larger_than(610, 640)
      end
    end

    context 'the large version' do
      it "should scale down a landscape image to be exactly 440 by 440 pixels" do
        # @uploader.large.should have_dimensions(440, 440)
        # @uploader.large_x.should be_no_wider_than(440)
        @uploader.large.should be_no_larger_than(440, 440)
      end
    end

    context 'the middle version' do
      it "should scale down a landscape image to be exactly 200 by 440 pixels" do
        # @uploader.middle.should have_dimensions(200, 440)
        @uploader.middle.should be_no_larger_than(200, 440)
      end
    end

    context 'the thumb_x version' do
      it "should scale down a landscape image to be exactly 100 by 100 pixels" do
        @uploader.thumb_x.should have_dimensions(100, 100)

      end
    end

    context 'the thumb version' do
      it "should scale down a landscape image to be exactly 130 by 130 pixels" do
        @uploader.thumb.should have_dimensions(130, 130)
      end
    end
end

context "Imageable is Winery" do	
  before do
    path_to_file = File.join(Rails.root, 'spec', 'support', 'rails.png')
    @photo = create(:photo_with_winery)
    # ImageUploader.enable_processing = true
    @uploader = ImageUploader.new(@photo, :image)
    #@uploader.should_process = false
    @uploader.store!(File.open(path_to_file))
  end

  after do
    ImageUploader.enable_processing = false
    @uploader.remove!
  end
  context 'the middle_x version' do
    it "should scale down a landscape image to be exactly 360 by 330 pixels" do
      # @uploader.middle_x.should have_dimensions(360, 330)
      @uploader.middle_x.should be_no_larger_than(360, 330)
    end
  end
end
end
# context 'the middle_x version' do
# 	it "should scale down a landscape image to fit within 200 by 200 pixels" do
# 		@uploader.image.middle_x.should be_no_larger_than(200, 200)
# 	end
# end

# it "should make the image readable only to the owner and not executable" do
# 	@uploader.image.should have_permissions(0644)
# end
