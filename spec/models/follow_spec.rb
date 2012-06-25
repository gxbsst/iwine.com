require 'spec_helper'

describe Follow do
  let(:follow){ Factory(:follow)}
  before(:each) do
    @follow = create(:follow)
  end
  context "new Record" do
    before(:each) do
      @follow = Follow.new()
      @follow.save
    end
    describe "#followable_type" do
      it "should have 1 error " do
        @follow.should have(1).error_on(:followable_type)
      end
    end
    describe "#user_id" do
      it "should have 1 error " do
        @follow.should have(1).error_on(:user_id)
      end
    end
    describe "#followable_id" do
      it "should have 1 error " do
        @follow.should have(1).error_on(:followable_id)
      end
    end
  end

  context "check field type" do
    describe "#followable_type" do
      it "should raise_error ActiveRecord::StatementInvalid" do
        @follow = Follow.new(:followable_type => "Wines::Detail")
        # expect {
        #   @follow.save
        # }.to raise_error(ActiveRecord::StatementInvalid)
        @follow = Follow.new(:followable_type => "Wines::Detail")
        @follow.save
        @follow.should have(1).error_on(:followable_id)
      end
    end

    describe "#followable_id" do
      it "should be kind of Fixnum" do
        @follow.followable_id.should be_kind_of(Fixnum)
      end
    end

    describe "#user_id" do
      it "should be kind of Integer" do
        @follow.user_id.should be_kind_of(Fixnum)
      end
    end

    describe "#private_type" do
      it "should be 1" do
        @follow.private_type.should be(1)
      end
    end

    describe "#is_share" do
      it "should be true" do
        @follow.is_share.should be_true
      end
    end
  end

end
