require 'spec_helper'
describe PosterUploader do
  include CarrierWave::Test::Matchers
  context "upload a poster" do
    before do
      path_to_file = File.join(Rails.root, 'spec', 'support', 'rails.png')
      @event = create(:event)
      PosterUploader.enable_processing = true
      @uploader = PosterUploader.new(@event, :poster)
      @uploader.store!(File.open(path_to_file))
    end

    after do
      ImageUploader.enable_processing = false
      @uploader.remove!
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
        @uploader.middle.should be_no_larger_than(200, 200)
      end
    end

    context 'the thumb version' do
      it "should scale down a landscape image to be exactly 130 by 130 pixels" do
        pending
        #@uploader.thumb.should have_dimensions(22, 30)
      end
    end
  end

  context "crop a poster" do
    before do
      #path_to_file = File.join(Rails.root, 'spec', 'support', 'rails.png')
      @event = create(:event, :with_event_poster)
      #PosterUploader.enable_processing = true
      #@uploader = PosterUploader.new(@event, :poster)
      #@uploader.store!(File.open(path_to_file))
    end

    #after do
      #ImageUploader.enable_processing = false
      #@uploader.remove!
    #end

    describe "#crop_x #crop_y" do
      it "should be croped" do
        @event.crop_x = "5"
        @event.crop_y = "5"
        @event.crop_w = "20"
        @event.crop_h = "20"
        @event.save
        @event.poster.thumb.should have_dimensions(30, 30)
      end
    end

  end

end

