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

  describe "State" do
    before(:each) do
      STATE_CODE = {:non_follow => 0, :following => 1, :follower => 2, :mutual_follow => 3}

      #@user_a = mock(User, :id => 1000)
      @user_a = mock_model(User, :id => 1000)
      #@user_a.stub(:id => 1000)
      @user_b = mock_model(User, :id => 10001)


      #@user_b.stub(:id => 1001)

      #@user_b = mock(User, :id => 1001)
      #@state = Service::FriendService::State.run(@user_a, @user_b)

      #@sns_name = 'sina'
    end

    it "return 1" do
      @user_a.stub(:is_following).with(@user_b.id) { true }
      @user_b.stub(:is_following).with(@user_a.id) { false }
      @user_a.is_following(@user_b.id).should be_true
      @state = Service::FriendService::State.run(@user_a, @user_b)
      @state.should == 1
    end

    it "return 2" do
      @user_a.stub(:is_following).with(@user_b.id) { true }
      @user_b.stub(:is_following).with(@user_a.id) { false }
      @user_a.is_following(@user_b.id).should be_true
      @state = Service::FriendService::State.run(@user_b, @user_a)
      @state.should == 2
    end

    it "return 3" do
      @user_a.stub(:is_following).with(@user_b.id) { true }
      @user_b.stub(:is_following).with(@user_a.id) { true }
      @user_a.is_following(@user_b.id).should be_true
      @state = Service::FriendService::State.run(@user_b, @user_a)
      @state.should == 3
    end

    it "return 0" do
      @user_a.stub(:is_following).with(@user_b.id) { false }
      @user_b.stub(:is_following).with(@user_a.id) { false }
      @user_a.is_following(@user_b.id).should be_false
      @state = Service::FriendService::State.run(@user_b, @user_a)
      @state.should == 0
    end





  end
end
