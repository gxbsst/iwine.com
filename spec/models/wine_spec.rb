# -*- coding: utf-8 -*-
require "spec_helper"

describe Wine do
  before do
    @wine = Wine.new(:name_zh => "这个是一个酒名", :name_en => "E Name")

  end

  it "应该..." do
    @wine.origin_name = "Origin Name "
    @wine.name_zh.should == "这个是一个酒名"
  end

  it "should bending" do
    # pending
  end

  it "保存不成功" do
    @wine.region_tree_id = 11
    @wine.winery_id = 12
    @wine.save.should be_true
  end

end


