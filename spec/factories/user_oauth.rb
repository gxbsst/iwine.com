# encoding: utf-8
FactoryGirl.define do
	factory :user_oauth, :class => "Users::Oauth" do
     user { |c| c.association(:user) }
  end
 
  trait :qq do
    sns_name "qq"
    sns_user_id "111111"
  end

  trait :sina do
    sns_name "sina"
    sns_user_id "111111"
  end

  trait :renren do
    sns_name "renren"
    sns_user_id "111111"
  end

  #trait :with_user do
    #after :create do |user|
       #FactoryGirl.create_list :profile, 1, :user => user
    #end
  #end
end

