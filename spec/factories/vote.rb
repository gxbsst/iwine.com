# encoding: utf-8
FactoryGirl.define do
	
	factory :vote, :class => "ActsAsVotable::Vote" do
	  votable {|c| c.association(:photo)}
	  voter {|c| c.association(:user)} 
	  vote_flag 1
	end
end