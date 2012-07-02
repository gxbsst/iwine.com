# encoding: utf-8
FactoryGirl.define do
	  
  factory :wine_cellar, :class => "Users::WineCellar" do
    user {|c|c.association(:user)}
    items_count 0
  end
end