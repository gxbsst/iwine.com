# encoding: utf-8
# example https://github.com/drhenner/ror_ecommerce/tree/master/spec/factories
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
  	commentable  { |c| c.association(:wine_detail) }
    user  { |c| c.association(:user) }
    parent_id ""
    point 3
  	# title
    body "Comment Body"
    votes_count 0
    children_count 0
    private 1
    is_share 1
  end

  factory :comment_with_winery, :class => "Comment" do
    commentable  { |c| c.association(:winery) }
    user  { |c| c.association(:user) }
    point 3
    "do" "follow"
    body "Comment Body"
    votes_count 0
    children_count 0
    private 1
    is_share 1
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
    valid_file = File.new(File.join(Rails.root, 'spec', 'support', 'rails.png'))
    audit_status 0
    image File.open(valid_file)
    imageable_type "Wines::Detail"
    user {|c| c.association(:user)}
    album {|c| c.association(:album)}
  end

  factory :audit_log do
    result 0
    owner_type 5
    created_by 1
    # business_id {|c| c.id }
    # sequence(:business_id) { i }
  end

  factory :wine_detail_with_photo, :parent => :wine_detail do |w|
    # valid_file = File.new(File.join(Rails.root, 'spec', 'support', 'rails.png'))
    # images {
    #   [
    #     ActionController::TestUploadedFile.new(valid_file, Mime::Type.new('application/png'))
    #   ]
    # }
    w.photos {|p|[p.association(:photo),
                  p.association(:photo)]}
  end

  factory :wine_detail_with_photo_and_audit_log, :parent => :wine_detail do |w|
    # valid_file = File.new(File.join(Rails.root, 'spec', 'support', 'rails.png'))
    # images {
    #   [
    #     ActionController::TestUploadedFile.new(valid_file, Mime::Type.new('application/png'))
    #   ]
    # }
    w.photos {|p|[p.association(:photo_with_audit_log),
                  p.association(:photo_with_audit_log)]}
  end

  factory :wine_cellar, :class => "Users::WineCellar" do
    user {|c|c.association(:user)}
    items_count 0
  end
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

  factory :album do
    user {|c| c.association(:user)}
    is_order_asc 1
    name "album title"
  end

  factory :album_with_photo, :parent => :album do |p|
    p.photos {|m|[m.association(:photo), m.association(:photo)]}
  end

  # factory :photo_with_audit_log, :parent => :photo, :class => Photo do |p|
  #   p.audit_logs {|p| [p.association(:audit_log),p.association(:audit_log)]}
  # end

  factory :comment_with_photo, :class => "Comment" do
    commentable  { |c| c.association(:photo) }
    user  { |c| c.association(:user) }
    parent_id ""
    point 3
    # title
    body "Comment Body"
    votes_count 0
    children_count 0
    private 1
    is_share 1
  end

  factory :vote, :class => "ActsAsVotable::Vote" do
    votable {|c| c.association(:photo)}
    voter {|c| c.association(:user)} 
    vote_flag 1
  end


  
end