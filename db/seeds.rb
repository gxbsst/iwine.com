# encoding: UTF-8
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

## 初始化 wine style
# 
#  styles = [
#      ['Red Wine', '红葡萄酒'],
#      ['White Wine', '粉红葡萄酒'],
#      ['Sparkling Wine', '起泡酒'],
#      ['Champagne Wine', '香槟酒'],
#      ['Port Wine', '波特酒'],
#      ['Sherry Wine', '雪利酒'],
#      ['Enhance Wine', '加强酒'],
#      ['Sweet Wine', '甜酒'],
#      ['Others', '其它']
#  ]
# # 
#  styles.each do |style|
#    Wines::Style.create(:name_en => style[0], :name_zh => style[1]) if Wines::Style.find_by_name_en(style[0]).blank?
#  end
# 
# ## 导入中国地区表
require 'csv'
 csv = CSV.read(Rails.root.join('db') + 'region.csv')
 
 csv.each do |item|
   puts item[3]
   Region.create(:parent_id => item[1], :region_name => item[2], :region_type => item[3].to_i ) if Region.find_by_region_name(item[2]).blank?
 end
# 
# ## TODO:
# # 导入 Variety
 # csv = CSV.read(Rails.root.join('db', 'wine_variety_i18n.csv'))
 # 
 # csv.each do |item|
 #   begin
 #     unless item[2].blank?
 #       item[2] = item[2].force_encoding 'utf-8'
 #       item[2].contains_cjk? ? pinyin = HanziToPinyin.hanzi_to_pinyin(item[2]) : pinyin = '' 
 #     end
 #     Wines::Variety.create(:name_zh => item[2], :name_en => item[0].to_ascii_brutal, :origin_name => item[0], :pinyin => pinyin) if Wines::Variety.find_by_origin_name(item[0]).blank?
 #   rescue Exception => e
 #     puts e
 #   end
 # end


## 导入一个酒款
#wine = {
#    'name_en' => '',
#    'name_zh' => '',
#    'official_site' => '',
#    'wine_style_id' => '',
#    'region_tree_id' => '',
#    'winery_id' => '',
#    'photo_name' => '',
#    'photo_origin_name' => '',
#    'vintage' => '2006',
#    'drinkable_begin' => '',
#    'drinkable_end' => '',
#    'alcoholicity' => '',
#    'variety_percentage' => '',
#    'variety_name' => '',
#    'capacity' => ''
#}

#Dir[Rails.root.join('db','images/1')].find_all{|x| File.file? x}.collect {|fn| [fn,File.open(fn){ |f| f.read }] }
# csv = CSV.read(Rails.root.join('db', 'wine_sample.csv'))
# 
# csv.each do |item|
#   begin
#     name_en = item[1].force_encoding('utf-8').to_ascii_brutal
#     origin_name = item[1].force_encoding 'utf-8'
#     name_zh = item[2].force_encoding 'utf-8'
#     official_site = item[3].force_encoding 'utf-8'
#     wine_style_id = 1
#     region_tree_id = 30
#     winery_id = 1
#     
#     @wine = Wine.create(
#     :name_en => name_en,
#     :origin_name => origin_name,
#     :name_zh => name_zh,
#     :official_site => official_site,
#     :wine_style_id => wine_style_id,
#     :region_tree_id => region_tree_id,
#     :winery_id => winery_id
#     )
# 
#     @wine_detail = Wines::Detail.create(
#     :drinkable_begin => item[9].split('-')[0].to_i,
#     :drinkable_end => item[9].split('-')[1].to_i,
#     :alcoholicity => '15%',
#     :wine_id => @wine.id,
#     :year => item[8]
#     )
#     puts @wine_detail.id
#     # # 保存葡萄含量
#     varieties = item[11].split /[\r\n]+/
#     # varieties.each do |i|
#     #   wp = Wines::VarietyPercentage.create(
#     #   :wine_detail_id => @wine_detail.id,
#     #   :percentage => i.split('/')[1],
#     #   :variety_id => Wines::Variety.find_by_name_en(i.split('/')[0]).first.id
#     #   )
#     # 
#     # end
#     #   # 保存图片
#       file_path = Rails.root.join('db', item[0], Dir.entries(Rails.root.join('db', item[0])).select{|x| x != '.' && x != '..'}.first)
#       # photo = Photo.create(:owner_type => 2, :business_id => 1, :image => File.read(a))
#       photo = Photo.create(:owner_type => 2, :business_id => @wine_detail.id, :image => open(file_path))
#     # @object.image.store!(image)
#   rescue Exception => e
#     puts e
#   end
  
# end

# Dir.entries(Rails.root.join('db','images/1')).select{|x| x != '.' && x != '..'}






