# encoding: utf-8
require 'spec_helper'

describe Event do

  context "initialize event" do
    before(:each) do 
      @event = Event.new  
    end

    describe "#title" do
      it "should be nil" do
        @event.title.should be_nil
      end
    end

    describe "#desription" do
      it "should be nil" do
        @event.description.should be_nil
      end
    end

    describe "#poster" do
      it "should eql /assets/userpic.jpg" do
        @event.poster_url.should == "/assets/userpic.jpg"
      end
    end

    describe "#begin_at" do
      it "should be nil" do
        @event.begin_at.should be_nil
      end
    end

    describe "#end_at" do
      it "should be nil" do
        @event.begin_at.should be_nil
      end
    end

    describe "#end_at" do
      it "should be nil" do
        @event.begin_at.should be_nil
      end
    end

    describe "#address" do
      it "should be nil" do
        @event.address.should be_nil
      end
    end

    describe "#publish_status" do
      it "should be 1" do
        @event.publish_status.should be(1) # 草稿状态 
      end
    end

    describe "#followers_count" do
      it "should be 0" do
        @event.followers_count.should be(0)
      end
    end

    describe "#participants_count" do
      it "should be 0" do
        @event.participants_count.should be(0)
      end
    end
  end

  context "create a events" do
    before(:each) do
      @event = create :event
    end
    describe "#title" do
      it "should be not nil" do
        @event.title.should_not be_nil
      end
    end

    describe "#desription" do
      it "should be not nil" do
        @event.description.should_not be_nil
      end
    end

    #describe "#poster" do
      #it "should be nil" do
        #@event.poster.should be_nil
      #end
    #end

    describe "#begin_at" do
      it "should be nil" do
        @event.begin_at.should == Time.parse('2014-12-20 00:00:00 ') 
      end
    end

    describe "#end_at" do
      it "should be nil" do
        @event.end_at.should == Time.parse('2014-12-30 00:00:00 ') 
      end
    end

    describe "#address" do
      it "should include 上海" do
        @event.address.should include("上海") 
      end

      
      it "latitude longitude" do
       Geocoder.coordinates(@event.address).first.should eql(31.230393)
       Geocoder.coordinates(@event.address).last.should  eql(121.473704)
      end

      it "should get near address" do
        result = Geocoder.coordinates("上海江桥")
        @client = GooglePlaces::Client.new("AIzaSyAA-avxg99B5P-rTQHuItTBZ17FvbbGI8A") 
        array =  @client.spots(result.first, result.last, :language => 'zh-CN') 
        array.size.should  be(20)
        array.first.name.should include("嘉定区")
      end

    end

    describe "#publish_status" do
      it "should be 1" do
        @event.publish_status.should be(2) # 发布状态 
      end
    end

    describe "#followers_count" do
      it "should be 0" do
        @event.followers_count.should be(0)
      end
    end

    describe "#participants_count" do
      it "should be 0" do
        @event.participants_count.should be(0)
      end
    end

    describe "#tags" do
      it "should have 2 tags" do
        @event.should have(2).tags
      end

      it "should can find tags with 故事" do
        Event.tagged_with("故事").first.title.should include("活动")
      end
    end

    describe "block_in" do
      it "should be 10" do
        @event.block_in.should be(10) 
      end
    end

  end

  context "validate Event" do
    before(:each) do
      @event = Event.create(:title => "test")
    end

    describe "#errors" do
      it "should have 3 errors" do
        @event.should have(4).errors 
      end
    end
  end

  context "user join in a event" do
    before(:each) do
      @user = create(:user)
      @event = create(:event)
      @ep_info = {:telephone => '13472466606',
        :user_id => @user.id,
        :email => @user.email,
        :note => "here is note",
        :username => @user.username}
    end
    describe "#participants_count"  do
      it "should be  1" do
       @user.join_event(@event, @ep_info)
       Event.find(@event).participants_count.should be(1)
       @participant = @user.cancle_join_event(@event, :cancle_note => 'cancle note') 
       @participant.join_status.should be(0)
       Event.find(@event).participants_count.should be(0)
      end
    end

    describe "#followers_count" do
      it "should have some change" do
       @user.follow_event(@event) 
       Event.find(@event).followers_count.should be(1)
       @user.cancle_follow_event(@event)
       Event.find(@event).followers_count.should be(0)
      end
    end
  end

  context "Invite User" do
   before(:each) do
     @event = create(:event)
     @inviter = create(:user)
     @invitee = create(:user)
   end

   describe "Invite on user" do
     it "should be successful" do
       @inviter.invite_one(@invitee.id, @event).confirm_status.should be(0)
     end
   end
  end

  context "Add a Wine" do
    before(:each) do
     @event = create(:event) 
     @wine = create(:wine_detail)
    end
    describe "#add_one_wine" do
      it "should be true" do
       @wine = @event.add_one_wine(@wine.id)
       @wine.wine_detail.name.should include("中国")
      end
    end
  end

end
