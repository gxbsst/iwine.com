# encoding: utf-8
FactoryGirl.define do
	 factory :comment_with_photo, :class => "Comment" do
    commentable  { |c| c.association(:photo) }
    user  { |c| c.association(:user) }
    parent_id ""
    point 3
    # title
    body "Comment Body"
    votes_count 0
    children_count 0
    private 1
    is_share 1
  end

end