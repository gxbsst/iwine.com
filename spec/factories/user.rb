# encoding: utf-8
FactoryGirl.define do
	factory :user do
		sequence(:username) { |n| "foo_1#{n}" }
		password "foobar"
		email { "#{username}@example.com" }
		city "Shanghai"
    # agree_term true
    factory :agree_term do
       agree_term true
    end
      # factory :admin do
    #   admin true
    # end
    # profile  { |c| c.association(:profile) }
  end
 
  trait :domained do
    domain "weixuhong"
  end

  trait :draft do
    domain nil
  end

  trait :error_domain do
    domain "&^-1#"
  end

  trait :with_profile do
    after :create do |user|
       FactoryGirl.create_list :profile, 1, :user => user
    end
  end
  
end
