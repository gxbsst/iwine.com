# encoding: UTF-8
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

## 初始化 wine style

styles = [
    ['Red Wine', '红葡萄酒'],
    ['White Wine', '粉红葡萄酒'],
    ['Sparkling Wine', '起泡酒'],
    ['Champagne Wine', '香槟酒'],
    ['Port Wine', '波特酒'],
    ['Sherry Wine', '雪利酒'],
    ['Enhance Wine', '加强酒'],
    ['Sweet Wine', '甜酒'],
    ['Others', '其它']
]

styles.each do |style|
    Wines::Style.create(:name_en => style[0], :name_zh => style[1]) if Wines::Style.find_by_name_en(style[0]).blank?
end

## 导入中国地区表
require 'csv'
csv = CSV.read(Rails.root.join('db') + 'region.csv')

csv.each do |item|
 puts item[3]
 Region.create(:parent_id => item[1], :region_name => item[2], :region_type => item[3].to_i ) if Region.find_by_region_name(item[2]).blank?
end



