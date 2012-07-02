# encoding: utf-8
FactoryGirl.define do
	factory :album do
	  user {|c| c.association(:user)}
	  is_order_asc 1
	  name "album title"
	end

end