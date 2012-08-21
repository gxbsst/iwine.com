# encoding: utf-8
FactoryGirl.define do
	factory :follow do
	  followable {|c| c.association(:wine_detail)}
	  user {|c| c.association(:user)} 
	  private_type 1
	  is_share true
	end

 factory :follow_event do
	  followable {|c| c.association(:event)}
	  user {|c| c.association(:user)} 
	  private_type 1
	  is_share true
	end


end
