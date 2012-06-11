# encoding: utf-8
# Factory.define :user do |f|
#   f.sequence(:email) { |n| "foo#{n}@example.com" }
#   f.password "secret"
# end

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
  
  factory :wine_detail, :class => "Wines::Detail" do
    drinkable_begin Time.now
    drinkable_end Time.now
    price 12
    capacity "10"
    wine_style_id 1
    wine_id 1 
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

  factory :wine do
  	name_zh "中国"
  	name_en "ename"
  	official_site "http://www.example.com"
  	wine_style_id 1
  	winery_id 1
  	region_tree 1
  	created_at Time.now
  	updated_at Time.now
  	origin_name "origin_name" 
  	other_cn "中文名1， 中文名2"
  end

  factory :comment do
  	# commentable_id
  	# commentable_type
  	# title
  	# body
  	# subject
  	# user_id
  	# parent_id
  	# lft
  	# rgt
  	# created_at
  	# updated_at
  	# point
  	# private
  	# is_share
  	# _config
  	# do
  	# deleted_at
  	# votes_count
  	# children_count
  end

  factory :winery do
  	name_en "ename"
  	region_tree_id 1
  	owner "weston"  
  	created_at Time.now
  	updated_at Time.now
  	name_zh "中问名"
  	logo "logo"    
  	address "shanghai"         
  	official_site "http://www.com.com"
  	email "email@example.com"       
  	cellphone "555555"      
  	# fax         
  	# config
  	# origin_name
  	# counts        
  	wines_count 0
  	photos_count 0
  	comments_count 0
  	followers_count 0
  end

  factory :photo do

  end

end