# encoding: utf-8
FactoryGirl.define do
	factory :audit_log do
    result 0
    owner_type 5
    created_by 1
    # business_id {|c| c.id }
    # sequence(:business_id) { i }
  end
end