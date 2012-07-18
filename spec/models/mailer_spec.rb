# -*- coding: utf-8 -*-
require "spec_helper"

describe "User Mailer" do
	before(:each) do
		@replier = create(:user, :with_profile)
		@commenter = create(:user)
		# @sender = create(:user, :with_profile)
		# @receiver = create(:user)
	end
	describe "#reply comment" do

		it "should receive email" do
			# @commenter.profile.config.notice.email = ['2','4','5']
			# @commenter.save

			@wine_detail = create(:wine_detail)
			@comment = Comment.build_from @wine_detail, @commenter.id, "Comment content" 
			@comment.do = "comment"
			@comment.save

			@reply_comment = ::Comment.build_from(@comment.commentable,
				@replier.id,
				"Reply Comment Body",
				:parent_id => @comment.id,
				:do => "comment")
			@reply_comment.save
			@reply_comment.move_to_child_of(@comment)

			last_email.to.should include(@commenter.email)
		end

	end

	describe "#message" do
		before(:each) do
		  @sender = create(:user, :with_profile)
		  @receiver = create(:user)
		end
		it "should receive email" do
			@sender.send_message([@receiver], "body", "subject", true)
			last_email.to.should include(@receiver.email)
		end

	end
end