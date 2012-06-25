# -*- coding: utf-8 -*-
require "spec_helper"

describe User do
  let(:user) { Factory(:user)}
  describe "#wines_count" do
    let(:wine_detail) { Factory(:wine_detail)}
    it "should increment if wines cellar item is created" do
      @wine_cellar_item = create(:wine_cellar_item, :wine_detail_id => wine_detail.id)
      User.find(@wine_cellar_item.user).wines_count.should be(1)
    end
    it "should increment if wines cellar item is destroyed" do
      @wine_cellar_item = build(:wine_cellar_item, :wine_detail_id => wine_detail.id)
      @wine_cellar_item.save
      @wine_cellar_item.destroy
      User.find(@wine_cellar_item.user).wines_count.should be(0)
    end
  end

  describe "#photos_count" do
    before(:each) do
      @photo = build(:photo)
    end
    it "should increment if Photo is created" do
      @photo.save
      User.find(@photo.user).photos_count.should be(1)
    end
    it "should decrement if Photo is destroyed" do
      @photo.deleted_at = Time.now
      @photo.save
      User.find(@photo.user).photos_count.should be(0)
    end
  end

  describe "#wine_followings_count" do
    before(:each) do
      @comment = build(:comment, :do => "follow")
    end
    it "should increment if do follow" do
      @comment.save
      User.find(@comment.user).wine_followings_count.should be(1)
    end
    it "should decrement if do follow" do
      @comment.deleted_at = Time.now
      @comment.save
      User.find(@comment.user).wine_followings_count.should be(0)
    end
  end

  # describe "#winery_followings_count" do
  #   before(:each) do
  #     @winery = create(:winery)
  #     @comment = Comment.build_from( @winery,
  #                                    user.id,
  #                                    'Comment body',
  #                                    :do => "follow")
  #   end
  #   it "should increment if do follow" do
  #     @comment.save
  #     User.find(user).winery_followings_count.should be(1)
  #   end
  #   it "should decrement if do follow" do
  #     @comment.save
  #     @comment.deleted_at = Time.now
  #     @comment.save
  #     User.find(user).winery_followings_count.should be(0)
  #   end
  # end
  describe "#comments_count" do
    before(:each) do
      @comment = build(:comment, :do => "comment")
    end
    it "should increment if do comment" do
      @comment.save
      User.find(@comment.user).comments_count.should be(1)
    end
    it "should decrement if do follow" do
      @comment.deleted_at = Time.now
      @comment.save
      User.find(@comment.user).comments_count.should be(0)
    end
  end


  describe "#followings_count" do
    before(:each) do
      @follower = create(:user)
    end
    it "should increment if follower follow user" do
      @follower.follow_user(user.id)
      User.find(@follower).followings_count.should be(1)
    end
    it "should increment if follower follow user" do
      @follower.unfollow(user)
      User.find(@follower).followings_count.should be(0)
    end
  end

  describe "#followers_count" do
    before(:each) do
      @follower = create(:user)
    end
    it "should increment if follower follow user" do
      @follower.follow_user(user.id)
      User.find(user).followers_count.should be(1)
    end
    it "should increment if follower follow user" do
      @follower.unfollow(user)
      User.find(user).followers_count.should be(0)
    end
  end

  describe "#albums_count" do
    before(:each) do
      @album = build(:album)

    end
    it "should increment if album is created" do
      @album.save
      User.find(@album.user).albums_count.should be(1)
    end
    it "should increment if album is destroy" do
      @album.save
      @album.destroy
      User.find(@album.user).albums_count.should be(0)
    end
  end
end
