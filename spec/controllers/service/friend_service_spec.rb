# -*- coding: utf-8 -*-
require 'spec_helper'
describe "Service::FriendService" do
  describe "Recommend" do
    before(:each) do
      @user = User.find_by_email('gxbsst@gmail.com')
      #@sns_name = 'sina'
    end

   context  'all' do
     it "return some friends" do
       friends = Service::FriendService::Recommend.call(@user)
       friends.size.should > 1
     end
   end

    context 'sina weibo' do
      it "return some friends" do
        friends = Service::FriendService::Recommend.call(@user, 'weibo')
        friends.size.should > 1
      end
    end

    context 'qq weibo' do
      it "return some friends" do
        friends = Service::FriendService::Recommend.call(@user, 'qq')
        friends.size.should > 1
      end
    end

    context 'douban' do
      it "return some friends" do
        friends = Service::FriendService::Recommend.call(@user, 'douban')
        friends.size.should > 1

      end
    end

    context 'sina weibo for iphone' do
      it "return some friends" do
        friends = Service::FriendService::Recommend.call_with_classify(@user, 'weibo')
        friends.should include("sina")
        friends.should include("tencent")
        friends.should include("douban")
        friends['sina'].size.should > 1
      end
    end

  end
end
