# -*- coding: utf-8 -*-
require "spec_helper"

describe Users::WineCellar do
  # let(:photo) { Factory(:photo)}
  describe "#photos_count" do
    it "should increment if photo is created" do
      @wine_cellar_item = build(:wine_cellar_item)
      @wine_cellar_item.save
      Users::WineCellar.find(@wine_cellar_item.wine_cellar).items_count.should be(1)
    end
    it "should decrement if photo updated by deleted_at" do
      @wine_cellar_item = build(:wine_cellar_item)
      @wine_cellar_item.save
      @wine_cellar_item.destroy
      Users::WineCellar.find(@wine_cellar_item.wine_cellar).items_count.should be(0)
    end
  end
end
