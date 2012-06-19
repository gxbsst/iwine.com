# -*- coding: utf-8 -*-
require "spec_helper"

describe Album do
  # let(:photo) { Factory(:photo)}
  describe "#photos_count" do
    it "should increment if photo is created" do
      @photo = build(:photo)
      @photo.save
      Album.find(@photo.album).photos_count.should be(1)
    end
    it "should decrement if photo updated by deleted_at" do
      @photo = build(:photo)
      @photo.deleted_at = Time.now
      @photo.save
      # @photo.destroy
      Album.find(@photo.album).photos_count.should be(0)
    end
  end
end
