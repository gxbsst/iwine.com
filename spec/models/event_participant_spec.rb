require 'spec_helper'

describe EventParticipant do

  context "join a event" do
    before(:each) do
      @user = create(:user)
      @event = create(:event)
      ep = EventParticipant.new(:telephone => '13472466606',
                                                :email => @user.email,
                                                :note => "here is note",
                                                :username => @user.username)
      @event_participant = @user.join_event(@event, ep)
    end

    describe "#user_id" do
      it "should" do

      end
    end

    describe "#event_id" do
      it "should" do

      end
    end

    describe "#telephone" do
      it "should" do

      end
    end

    describe "#email" do
      it "should" do

      end
    end

    describe "#note" do
      it "should" do

      end
    end


    describe "#username" do
      it "should" do

      end
    end

    describe "#join_status" do
      it "should" do

      end
    end

    describe "#cancle_note" do
      it "should" do

      end
    end

  end

end
