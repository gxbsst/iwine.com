# encoding: utf-8
FactoryGirl.define do
  factory :event do
    user  { |c| c.association(:user) }
    region  { |c| c.association(:region) }
    title "这个是一个活动"
    description "这个是活动的内容"
    address "上海市内茶陵北路20号"
    begin_at (Time.parse '2008-12-10') + 10.days
    end_at (Time.parse '2008-12-10') + 20.days
    block_in 10
    pulish_status 1
    followers_count 0
    participants_count 0
    longitude "22222"
    latitude "33333"
    tag_list "产品, 故事"
    # profile  { |c| c.association(:profile) }
  end


  
  trait :with_event_followers do
    ignore do
      number_of_followers 3
    end
    after :create do |event, evaluator|
      FactoryGirl.create_list :follow_event,
        evaluator.number_of_followers, 
        :event => event
    end
  end

  trait :with_event_participants do
    ignore do
      number_of_participants 3
    end
    after :create do |event, evaluator|
      FactoryGirl.create_list :event_participants, 
        evaluator.number_of_participants, 
        :event => event
    end
  end


  trait :with_event_wines do
    ignore do
      number_of_wines 3
    end
    after :create do |event, evaluator|
      FactoryGirl.create_list :event_wine, evaluator.number_of_wines, :event => event
    end
  end

  # USAGE
  # FactoryGirl.create :event, :with_comments, :number_of_comments => 4
  trait :with_event_comments do
    ignore do
      number_of_comments 3
    end
    after :create do |event, evaluator|
      FactoryGirl.create_list :comment, evaluator.number_of_comments, :event => event
    end
  end

  trait :with_event_poster do
    path_to_file = File.join(Rails.root, 'spec', 'support', 'rails.png')
    poster File.open(path_to_file)
  end

end

