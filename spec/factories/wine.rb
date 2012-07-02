# encoding: utf-8
FactoryGirl.define do
	 factory :wine do
    winery  { |c| c.association(:winery) }
  	name_zh "中国"
  	name_en "ename"
  	official_site "http://www.example.com"
  	wine_style_id 1
  	region_tree_id 1
  	created_at Time.now
  	updated_at Time.now
  	origin_name "origin_name" 
  	other_cn_name "中文名1， 中文名2"
    photos_count 0
  end

end