# encoding: utf-8

FactoryGirl.define do
	factory :comment_with_winery, :class => "Comment" do
		commentable  { |c| c.association(:winery) }
		user  { |c| c.association(:user) }
		point 3
		"do" "follow"
		body "Comment Body"
		votes_count 0
		children_count 0
		private 1
		is_share 1
	end
end