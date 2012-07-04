# encoding: utf-8
FactoryGirl.define do
	 factory :wine_cellar_item, :class => "Users::WineCellarItem" do |i|
    price "22"
    inventory 11
    drinkable_begin Time.now
    drinkable_end   Time.now + 2.years
    buy_from "Shanghai"
    buy_date 2.days.ago
    location "Baise"
    private_type 1
    value 22.22
    number 11
    user_wine_cellar_id 1
    user {|c| c.association(:user)}
    wine_detail {|c| c.association(:wine_detail)}
    wine_cellar {|c| c.association(:wine_cellar)}
  end
end