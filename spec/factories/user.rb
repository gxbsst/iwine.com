# encoding: utf-8
FactoryGirl.define do
	factory :user do
		sequence(:username) { |n| "foo_1#{n}" }
		password "foobar"
		email { "#{username}@example.com" }
		city "Shanghai"
      # factory :admin do
    #   admin true
    # end
  end
  
end