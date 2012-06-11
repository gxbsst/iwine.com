require 'spec_helper'
describe Wines::Detail do
	let(:user) { Factory(:user) }
	it "comments_count will +1 when Comment create" do
		@wine_detail = create(:wine_detail)
		# @user = create(:user, city: "Shanghai", username: "user3")
		# @user.errors.on(:email) 
		# @user.should_not_be_valid
		@comment = Comment.build_from @wine_detail, user.id, "Comment content"
		@comment.save
		@comment = Comment.build_from @wine_detail, user.id, "Comment content"
		@comment.save
		@comment = Comment.build_from @wine_detail, user.id, "Comment content"
		@comment.save
		@new_wine_detail = Wines::Detail.find(@wine_detail)
		# Rails.logger("....")
		@new_wine_detail.comments_count.should  be(3)

		@winery = create(:winery)
		@comment1 = Comment.build_from @winery, user.id, "Comment content"
		@comment1.save

		@reply_comment = Comment.build_from(@winery,
			user.id,
			"comment body",
			:parent_id => @comment1.id,
			:do => "comment")
		@reply_comment.save
		@reply_comment.move_to_child_of(@comment1)

		@user = User.find(user)
		@user.comments_count.should be(4)

		@new_winery = Winery.find(@winery)
		@new_winery.comments_count.should be(1)
	end

end

describe Wines::Detail do
	let(:user) { Factory(:user) }
	it "winery's comments count will be + 1" do
		@winery = create(:winery)
		@comment1 = Comment.build_from @winery, user.id, "Comment content"
		@comment1.save
		@new_winery = Winery.find(@winery)
		@new_winery.comments_count.should be(1)
	end
end