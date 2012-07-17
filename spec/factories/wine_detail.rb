# encoding: utf-8
# http://arjanvandergaag.nl/blog/factory_girl_tips.html
FactoryGirl.define do
	factory :wine_detail, :class => "Wines::Detail" do
    drinkable_begin Time.now
    drinkable_end Time.now
    price 12
    capacity "10"
    wine_style_id 1
    wine  { |c| c.association(:wine) } 
    year Time.now
    audit_id 1
    created_at Time.now
    updated_at Time.now                                        
    description "TEST Description"
    user_id 1
    photos_count 0                       
    comments_count 0
    followers_count 0                    
    owners_count 0                     
    tasting_notes_count 0
    events_count 0                 
    # is_nv true   
    # city       
    # user
  end

  trait :with_comments do
    ignore do
      number_of_comments 3
    end

    after :create do |wine_detail|
      FactoryGirl.create_list :comment, 3, :wine_detail=> wine_detail
    end
  end

  # USAGE
  # FactoryGirl.create :post, :with_comments, :number_of_comments => 4
end

#FactoryGirl.define do
  #factory :user, :aliases => [:author] do
    #username 'anonymous'
  #end

  #factory :post do
    #author # => populated with the user factory
  #end
#end
