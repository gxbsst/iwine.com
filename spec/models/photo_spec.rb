# require 'carrierwave/test/matchers'
# require 'spec_helper'
# require File.dirname(__FILE__) + '/../spec_helper'

# describe ImageUploader do
#   include CarrierWave::Test::Matchers
#   let(:user) { Factory(:user) }
#   before(:each) do
#     ImageUploader.enable_processing = true
#     @file = File.open("/Users/weston/Desktop/winery_img.png")
#   end

#   describe Photo, "Wine" do
#     before(:each) do
#       # @wine_detail = create(:wine_detail)
#       # @new_photo = @wine_detail.photos.build
#       # @new_photo.image = @file
#       # @new_photo.audit_status = 0
#       # @new_photo.save
#       # @audit_log = AuditLog.create(:owner_type => 5, :business_id => @new_photo.id, :result => @new_photo.audit_status)
#     end

#     it "audit_status should 0" do
#       # @new_photo.audit_status.should be(0)
#     end

#     it "counts_should_increment should be true" do
#       # pending
#       @wine_detail = create(:wine_detail)
#       @new_photo = @wine_detail.photos.build
#       @new_photo.image = @file
#       @new_photo.audit_status = 0
#       @new_photo.save
#       @audit_log = AuditLog.create(:owner_type => 5, :business_id => @new_photo.id, :result => @new_photo.audit_status)

#       find_photo = Photo.find(@new_photo)
#       find_photo.update_attribute(:audit_status, 2)

#       puts "#{find_photo.audit_migrate_status}........."
#       find_photo.audit_migrate_status.should_not be_empty

#       # expect {
#       # 		@find_photo.update_attributes(:audit_status => 1)
#       # 	}.to change{@find_photo.audit_migrate_status}.by(1)
#       # @find_photo.audit_migrate_status.should be(1)
#       # find_photo.counts_should_increment?.should be_true
#     end

#     # it "photos_count should be incremment " do
#     #  find_photo = Photo.find(@new_photo)
#     #  find_photo.update_attribute(:audit_status, 1)
#     #  find_photo.counts_should_increment?.should be_true
#     #  # Wines::Detail.find(@wine_detail).photos_count.should be(1)
#     # end

#     # it "photos_count should  be decremment " do
#     #   # @new_photo.save
#     #   @find_photo = Photo.find(@new_photo)
#     #   @find_photo.update_attributes(:audit_status => 1)
#     #   find_photo = Photo.find(@new_photo)
#     #   find_photo.update_attributes(:audit_status => 2)
#     #   # find_photo.audit_migrate_status.should be(3)
#     #   # find_photo = Photo.find(@new_photo)
#     #   # find_photo.update_attributes(:audit_status => 2)
#     #   # find_photo.counts_should_decrement?.should be_true
#     #   Wines::Detail.find(@wine_detail).photos_count.should be(0)
#     # end


#   end

#   describe Photo, "Winery" do

#   end

#   describe Photo, " Album" do

#   end

#   describe Photo, "Comment" do

#   end

# end

# -*- coding: utf-8 -*-
require "spec_helper"

describe Photo do
  # let(:photo) { Factory(:photo)}
  describe "#comments_count" do
    before(:each) do
      @comment = build(:comment_with_photo)
    end
    it "should increment if photo is commented" do
      @comment.save
      Photo.find(@comment.commentable).comments_count.should be(1)
    end
    it "should decrement if comment is deleted_at" do
      @comment.save
      @comment.deleted_at = Time.now
      @comment.save
      Photo.find(@comment.commentable).comments_count.should be(0)
    end
  end

  describe "#votes_count" do
    let(:photo) { Factory(:photo)}
    let(:user)  { Factory(:user)}
    it "should increment if photo is commented" do
      @vote = photo.liked_by user
      Photo.find(photo).votes_count.should be(1)
    end
   #  it "should decrement if comment is deleted_at" do
   #    photo.unlike_by user
	  # Photo.find(photo).votes_count.should be(0)      
   #    # vote =
   #    # @vote.destroy
   #    # Photo.find(photo).votes_count.should be(1)
   #  end
  end

  describe "#image" do
    before(:each) do
     @photo = build(:photo)  
    end
    it "should have image name" do
      @photo.save
      Photo.find(@photo).image_url.should_not be_empty 
    end

    it "should not have thumb url" do
      @photo.save
      Photo.find(@photo).image_url(:thumb).should_not be_empty 
    end
  end


end
