# encoding: utf-8
FactoryGirl.define do
	factory :region_tree, :class => 'Wines::RegionTree' do
  name_en "Lodi"
  parent_id 56
  name_zh "落迪"
  tree_right 0
  tree_left 0
  level 5
  origin_name "Lodi"
  doc "AVA"
  scope 0
 end
end
