# encoding: utf-8
FactoryGirl.define do
  factory :event_participant do
    user  { |c| c.association(:user) }
    event { |c| c.association(:event) }
    username "weixuhong"
    email "gxbsst@gmail.com"
    telephone "13472466606"
    note "here is note"
  end

end


