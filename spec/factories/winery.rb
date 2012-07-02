# encoding: utf-8
FactoryGirl.define do
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

end