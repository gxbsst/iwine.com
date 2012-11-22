# -*- coding: utf-8 -*-
require "spec_helper"

describe Users::Profile do

  context "configed" do
    before(:each) do
     @user = create(:user, :with_profile)
     @user.profile.config.share.wine_cellar = '1'
     @user.profile.config.share.wine_detail_comment = '1'
     @user.profile.config.notice.message = '1'
     @user.profile.config.notice.email = ['1', '2', '3', '4', '5']
    end

    describe "#share" do
      describe "#wine_cellar" do
        it "should be 1" do
          @user.profile.config.share.wine_cellar.should == '1'
        end
        it "should share when add a wine to cellar" do
         @user.share_when_add_wine_to_cellar?.should be_true 
        end 
      end
      describe "#wine_detail_comment" do
       it "should be 1" do
          @user.profile.config.share.wine_detail_comment.should == '1'
       end
       it "should share when comment a wine" do
        @user.share_when_do_wine_detail_comment?.should be_true
       end
      end
      describe "#wine_simple_comment" do
       # @user.share_wine_detail_comment.should be_true
      end
      describe "#wine_simple_comment" do
      end
    end

    describe "#message" do
      describe "#comment" do
        it "should be '1'" do
           @user.profile.config.notice.message.should == '1'
        end
        it "should recieve message from all user" do
          @user.receive_message_from_all?.should be_true
        end
      end
    end

    describe "#email" do
      describe "#message" do
        it "should include '1'" do
           @user.profile.config.notice.email.should include('1')
        end
        it "should recieve email when messaged" do
           @user.receive_email_when_messaged?.should be_true
        end
      end
      describe "#reply comment" do
        it "should include 2" do
          @user.profile.config.notice.email.should include('2')
        end
        it "should recieve email when comment be replied" do
          @user.receive_email_when_comment_replied?.should be_true
        end
      end
      describe "#be_followed" do
        it "should include 3" do
          @user.profile.config.notice.email.should include('3')
        end
        it "should recieve email when  be followed" do
         @user.receive_email_when_followed?.should be_true
        end
      end
      describe "#new product info" do
        it "should include 4" do
          @user.profile.config.notice.email.should include('4')
        end
        it "should recieve product info email " do
         @user.receive_product_info_email?.should be_true
        end
      end
      describe "#account or lib" do
        it "should include 5" do
          @user.profile.config.notice.email.should include('5')
        end
        it "should recieve account info email " do
         @user.receive_acount_info_email?.should be_true
        end
      end
    end
  end # end context

  context "none configed" do 
    before(:each) do
     @user = create(:user, :with_profile)
     @user.profile.config.share.wine_cellar = ''
     @user.profile.config.share.wine_detail_comment = ''
     @user.profile.config.notice.message = ''
     @user.profile.config.notice.email = []
    end

    describe "#share" do
      describe "#wine_cellar" do
        it "should be 1" do
          @user.profile.config.share.wine_cellar.should == ''
        end
        it "should share when add a wine to cellar" do
         @user.share_when_add_wine_to_cellar?.should be_false
        end 
      end
      describe "#wine_detail_comment" do
       it "should be 1" do
          @user.profile.config.share.wine_detail_comment.should == ''
       end
       it "should share when comment a wine" do
        @user.share_when_do_wine_detail_comment?.should be_false
       end
      end
      describe "#wine_simple_comment" do
       # @user.share_wine_detail_comment.should be_true
      end
      describe "#wine_simple_comment" do
      end
    end

    describe "#message" do
      describe "#comment" do
        it "should be '1'" do
           @user.profile.config.notice.message.should == ''
        end
        it "should recieve message from all user" do
          @user.receive_message_from_all?.should be_false
        end
      end
    end

    describe "#email" do
      describe "#message" do
        it "should include '1'" do
           @user.profile.config.notice.email.should_not include('1')
        end
        it "should recieve email when messaged" do
           @user.receive_email_when_messaged?.should be_false
        end
      end
      describe "#reply comment" do
        it "should include 2" do
          @user.profile.config.notice.email.should_not include('2')
        end
        it "should recieve email when comment be replied" do
          @user.receive_email_when_comment_replied?.should be_false
        end
      end
      describe "#be_followed" do
        it "should include 3" do
          @user.profile.config.notice.email.should_not include('3')
        end
        it "should recieve email when  be followed" do
         @user.receive_email_when_followed?.should be_false
        end
      end
      describe "#new product info" do
        it "should include 4" do
          @user.profile.config.notice.email.should_not include('4')
        end
        it "should recieve product info email " do
         @user.receive_product_info_email?.should be_false
        end
      end
      describe "#account or lib" do
        it "should include 5" do
          @user.profile.config.notice.email.should_not include('5')
        end
        it "should recieve account info email " do
         @user.receive_acount_info_email?.should be_false
        end
      end
    end

  end # end context
end
