# -*- coding: utf-8 -*-
require "spec_helper"

describe Friendship do
	# let(:user) { Factory(:user)}
	before(:each) do
		@user = create(:user, :with_profile)
		@follower = create(:user)
	end

	context "receive email" do
		before(:each) do
		  @user.profile.config.share.wine_cellar = '1'
		  @user.profile.config.share.wine_detail_comment = '1'
		  @user.profile.config.notice.message = '1'
		  @user.profile.config.notice.email = ['2','4','5', '1', '3']
		  @user.save
		end
		describe "#follow_user" do 
			it "be true" do
				@user.receive_email_when_followed?.should be_true
			end
			it "should send email when follow a user" do
				@follower.follow_user(@user.id)
				last_email.to.should include(@user.email)
			end
		end
	end

	context "not receive email" do
		before(:each) do
		   @user.profile.config.notice.email = []
		   @user.save
		end

		describe "#follow_user" do 
			it "be false" do
				@user.receive_email_when_followed?.should be_false
			end
			it "should send email when follow a user" do
				@follower.follow_user(@user.id)
				last_email.to.should_not include(@user.email)
			end
		end

	end

end
