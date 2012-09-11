require 'spec_helper'

describe EventParticipant do

  context "join a event" do
    before(:each) do
      @user = create(:user)
      @event = create(:event)
      ep_info = {:telephone => '13472466606',
                 :user_id => @user.id,
                 :email => @user.email,
                 :note => "here is note",
                 :username => @user.username}
      @participant = @user.join_event(@event, ep_info)
    end

    describe "#user_id" do
      it "should not nil" do
        @participant.user_id.should_not be_nil
      end
    end

    describe "#event_id" do
      it "should eql @participant.event_id" do
        @participant.event_id.should be(@event.id)
      end
    end

    describe "#telephone" do
      it "should be 13472466606" do
        @participant.telephone.should eql("13472466606") 
      end
    end

    describe "#email" do
      it "should be gxbsst@gmail.com" do
        @participant.email.should include("foo") 
      end
    end

    describe "#note" do
      it "should be nil" do
        @participant.note.should_not be_nil
      end
    end

    describe "#username" do
      it "should eql gxbsst" do
        @participant.username.should_not be_nil
      end
    end

    describe "#join_status" do
      it "should be 2" do
        @participant.join_status.should be(1) # 参加状态
      end
    end

    describe "#cancle_note" do
      it "should" do
        @participant.cancle_note.should be_nil 
      end
    end

    describe "#people_num" do
      it "should be 1" do
        @participant.people_num.should be(1)
      end
    end

  end

  context "join a event with validate" do
    before(:each) do
      @user = create(:user)
      @event = create(:event)
      ep_info = {:telephone => '',
        :user_id => @user.id,
        :email => '',
        :username =>''} 
      @participant = @user.join_event(@event, ep_info)
    end

    describe "#telephone" do
      it "should have error on telephone"  do
        @participant.should have(1).error_on(:telephone)
      end
    end

    describe "#email" do
      it "should have 2 error on email"  do
        @participant.should have(2).error_on(:email)
      end
      it "should have 1 error on email"  do
        @participant.email = "abc"
        @participant.save
        @participant.should have(1).error_on(:email)
      end
    end

    describe "#username" do
      it "should have error on username"  do
        @participant.should have(1).error_on(:username)
      end
    end
    
  end

  context "update join event info" do
    before(:each) do
      @event = create(:event, :with_event_participants, :number_of_participants => 3) 
      @participant = @event.participants.first 
      @user = @participant.user
      @info = {:telephone => '13472466606',
        :user_id => 2,
        :email => "",
        :note => "here is note",
        :username => "weixuhong"}
    end

    it "event locked? should be false" do
     @event.locked?.should be_false
    end

    context "event is living" do
      before(:each) do
      @participant = @user.update_join_event_info(@participant, @info)
      end
     describe "#email" do
       it "should have error on email"  do
        @participant.should have(2).errors_on(:email)  
       end
     end
    end
    
    context "event is locked" do
      before(:each) do
        @event.publish_status = 3 # locked
        @event.save
        @participant = @user.update_join_event_info(@participant, @info)
      end

      describe "#joinedable?" do
        it "should be false" do
         @event.joinedable?.should be_false 
        end
      end

      describe "#locked?" do
        it "should be true" do
         @event.locked?.should be_true
        end
      end
      
      describe "join a locked event" do
        it "@participant should return false" do
         @participant.should be_false 
        end
      end
       
    end
  
  end


end
