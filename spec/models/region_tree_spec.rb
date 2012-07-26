# -*- coding: utf-8 -*-
require "spec_helper"

describe Wines::RegionTree do
 let(:region_tree) { Factory(:region_tree) }

  describe "#name_en" do
   it "should be Lodi" do
    region_tree.name_en.should=="Lodi"
   end
  end

  describe "#get_parent_ids" do
   it "should 4 items" do
     region_tree.get_parent_ids.should have(4).items
   end
  end

  describe "#get_child_ids" do
    before(:each) do
      @region_tree = Wines::RegionTree.find(377) #China
    end
    it "should 3 items" do
      @region_tree.get_child_ids.should have(10).items
    end
    it "should 3 items" do
      region_tree.get_child_ids.should have(1).items
    end
  end

  describe "#root_parent_id" do
    context "parent is itself" do
      before(:each) do
        @region = Wines::RegionTree.find(377) #China
      end
      it "should be 377" do
        @region.root_parent_id.should be(377)
      end
    end

    context "parent is not it self" do
      before(:each) do
        @region = Wines::RegionTree.find(509) #China
      end
      it "should 377" do # china
       @region.root_parent_id.should be(377) 
      end
    
    end
  end
end
