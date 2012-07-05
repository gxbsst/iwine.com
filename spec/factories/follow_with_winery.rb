# encoding: utf-8
FactoryGirl.define do
	  factory :follow_with_winery, :class => 'Follow' do
    followable {|c| c.association(:winery)}
    user {|c| c.association(:user)} 
    private_type 1
    is_share true
  end
end