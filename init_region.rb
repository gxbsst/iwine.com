# encoding: UTF-8

require 'csv'
csv = CSV.read('db/region_tree.csv')

csv.each do |item|
  # 格式 0 2 4 6
  # ["中国", "china", "上海", "Shanghai"] => {"中国"=>"china", "上海"=>"Shanghai"}

  #item_to_hash = Hash
  item_to_hash = Hash[*item]

  parent = 0

  item_to_hash.each do |key, value|
    puts ( value)
    unless key.blank?
      value = value.force_encoding("ISO-8859-1").encode("UTF-8")
      # TODO:
      # 如果处理以下
      # 1. 法国,France,波尔多,Bordeaux,梅多克,Médoc,梅多克,Médoc
      # 2. 添加一个字段， 保存原生文字，如:RhÃ´ne Valley, name_en 保存 RhA´ne Valley
      # 转换方法: "Moulis/ Moulis-en-MÃ©doc".to_ascii_brutal => https://github.com/tomash/ascii_tic
      region = RegionTree.where("name_zh='" + key + "'").first
      region = RegionTree.create( :name_zh => key, :name_en => value, :parent_id => parent, :scope => 0, :tree_left => 0, :tree_right => 0)   if region.blank?
      parent = region.id
    end
  end


  ## 保存地区 0
  #unless  item[0].blank?
  #  region_0 =  RegionTree.where("name_zh='" + item[0] + "'")
  #  region_0 = RegionTree.create( :name_zh => item[0], :name_en => item[1], :parent => 0)   if region_0.blank?
  #end
  #
  ### 保存地区 1
  #unless  item[2].blank?
  #
  #  region_1 =  RegionTree.where("name_zh='" + item[2] + "'")
  #  region_1 = RegionTree.create( :name_zh => item[2], :name_en => item[3], :parent => region_0[0].id)  if region_1.blank?
  #end
  ## 保存地区 2
  #unless  item[4].blank?
  #
  #  region_2 =  RegionTree.where("name_zh='" + item[4] + "'")
  #  region_2 = RegionTree.create( :name_zh => item[4], :name_en => item[5], :parent => region_1[0].id)    if region_2.blank?
  #end
  #
  ### 保存地区 3
  #unless  item[6].blank?
  #  region_3 =  RegionTree.where("name_zh='" + item[6] + "'")
  #  region_3 = RegionTree.create( :name_zh => item[6], :name_en => item[7], :parent => region_2[0].id)   if region_3.blank?
  #end

end

