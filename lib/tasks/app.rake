#encoding: UTF-8
namespace :app do
  desc "TODO"
  task :upload_one_wine => :environment do
    require 'csv'
    styles = [
      ['Red Wine', '红葡萄酒'],
      ['White Wine', '白葡萄酒'],
      ['Rose Wine', '粉红葡萄酒'],
      ['Sparking Wine', '起泡酒'],
      ['Port Wine', '波特酒'],
      ['Sherry Wine', '雪利酒'],
      ['Fortified Wine', '加强酒'],
      ['Sweet Wine', '甜酒'],
      ['Others', '其它']
    ]

    #
    # ## 导入酒类表
    styles.each do |s|
      w = Wines::Style.where("name_en = ? and name_zh =? ", s[0], s[1]).first_or_create(:name_en => s[0], :name_zh => s[1])
    end

    #
    # ## 导入中国地区表
    regions = CSV.read("#{Rails.root}/lib/region.csv")
    regions.each do |r|
      Region.find_or_create_by_parent_id_and_region_name_and_region_type(r[1], r[2], r[3].to_i)
    end
  end

  desc "TODO"
  task :init_varieties => :environment do
    require 'csv'
    #
    # ## 导入酒庄
    varieties = CSV.read("#{Rails.root}/lib/wine_variety_i18n.csv")
    varieties.each do |v|
      begin
        unless v[2].blank?
          v[2] = v[2].force_encoding 'utf-8'
          pinyin = v[2].contains_cjk? ? HanziToPinyin.hanzi_to_pinyin(v[2]) : ''
        end
        Wines::Variety.create(:name_zh => v[2], :name_en => v[0].force_encoding('utf-8').to_ascii_brutal, :origin_name => v[0], :pinyin => pinyin) if Wines::Variety.find_by_origin_name(v[0]).nil?
      rescue Exception => e
        puts e
      end

    end
  end

  desc "TODO"
  task :upload_all_wines => :environment do
    require 'csv'
    ## 导入酒和详细信息
    file_path = Rails.root.join("lib/tasks/data/wines_datas.csv")
    csv  = CSV.read(file_path)
    csv.each do |item|
      begin
        region_tree = Wines::RegionTree.where("origin_name = ? and level = ?", item[5].to_s.split('/').last, item[5].to_s.split('/').size).first
        unless region_tree
          puts "#{item[5]}  region_tree_id can't be blank!"
          next
        end
        #处理适饮年限
        if item[10].to_s.include?('+')
          drinkable_begin = item[10].to_s.gsub(/\+/, '')
          drinkable_end = nil
        else
          drinkable_begin = item[10].to_s.split('-').first
          drinkable_end = item[10].to_s.split('-').last
        end

        #酒类品种及百分比处理
        variety_arr = item[12].to_s.gsub(/\n/, '/').force_encoding('utf-8').split('/')
        next if variety_arr.size.odd?
        variety_percentage = []
        variety_name = []
        Hash[*variety_arr].each do |key, value|
          variety_name.push key
          variety_percentage.push value
        end
        # get wine_style_id
        wine_style = Wines::Style.where("name_zh = ? ", item[4]).first
        #查找酒庄
        winery = Winery.where("name_en = ? ", item[7].to_s.force_encoding('utf-8').to_ascii_brutal).first
        wine_register = Wines::Register.find_or_initialize_by_name_en_and_vintage(item[1].to_s.force_encoding('utf-8').to_ascii_brutal, item[9])
        if wine_register.new_record?
          wine_register.name_zh = item[2].to_s.force_encoding('utf-8').split('/').last
          wine_register.name_en = item[1].to_s.force_encoding('utf-8').to_ascii_brutal
          wine_register.origin_name = item[1].to_s.force_encoding 'utf-8'
          wine_register.official_site = item[3].to_s.force_encoding('utf-8').gsub(/http:\/\//, '')
          wine_register.wine_style_id =  wine_style.id if wine_style #需要更改数据
          wine_register.region_tree_id = region_tree.id
          wine_register.winery_id = winery.id if winery
          wine_register.vintage = DateTime.parse "#{item[9]}-01-01" if item[9] != "NV" && item[9].present?
          wine_register.is_nv = 1 if item[9].to_s == "NV"
          wine_register.drinkable_begin = drinkable_begin.to_i == 0 ? nil : drinkable_begin.to_i
          wine_register.drinkable_end = drinkable_end.to_i == 0 ? nil : drinkable_end.to_i
          wine_register.alcoholicity =item[11]
          wine_register.variety_percentage = variety_percentage
          wine_register.variety_name = variety_name
          wine_register.capacity = item[13]
          wine_register.user_id = -1
          wine_register.status = 0
          wine_register.result = 0
          # process photo
          photo_path  = Rails.root.join('lib', 'tasks','data', 'wine_photos', item[0])

          if Dir.exist? photo_path
            file_path = Rails.root.join(photo_path, Dir.entries(photo_path).select{|x| x != '.' && x != '..' && x != '.DS_Store'}.first)
            wine_register.photo_name = open(file_path)
            File.delete(file_path) #删除此照片
          end
          wine_register.save
        end
       puts wine_register.id
      rescue Exception => e
        puts e
      end
    end
  end

  #发布酒
  desc "TODO"
  task :approve_wines => :environment do
    require 'csv'
    # 文件复制
    require 'fileutils'
    #检查图片路径
    Dir.mkdir "#{Rails.root}/public/uploads/photo" unless Dir.exist? "#{Rails.root}/public/uploads/photo"
    Dir.mkdir "#{Rails.root}/public/uploads/photo/wine" unless Dir.exist? "#{Rails.root}/public/uploads/photo/wine"

    Wines::Register.where("status = ? ", 0).each do |wine_register|
      begin
        Wine.transaction do
          wine_register.approve_wine
          puts wine_register.id
        end
      rescue Exception => e
        wine_register.update_attribute(:status, -1)
        puts e
      end
    end
  end

  desc "TODO"
  task :init_region_tree => :environment do
    require 'csv'
    # TODO: “请修改下面的路径”
    file_path = Rails.root.join("lib/tasks/data/region_tree/region_tree.csv")
    csv = CSV.read(file_path)
    csv.each do |item|
        item.collect{|i| i.to_s.force_encoding('utf-8')}
        #最后两列分别为空和doc,需要单独处理
        doc = item.pop #拿出doc
        item.pop #去掉空列
        item_to_hash = Hash[*item]
        parent = 0
        level = 1
        item_to_hash.each do |key, value|
          unless value.blank?
            ascii_value = value.to_ascii_brutal
            name_zh = key.blank? ? ascii_value : key
            # TODO:
            # 如果处理以下
            # 1. 法国,France,波尔多,Bordeaux,梅多克,Médoc,梅多克,Médoc
            # 2. 添加一个字段， 保存原生文字，如:RhÃ´ne Valley, name_en 保存 RhA´ne Valley
            # 转换方法: "Moulis/ Moulis-en-MÃ©doc".to_ascii_brutal => https://github.com/tomash/ascii_tic
            region = Wines::RegionTree.where("name_en = ? and level = ? ", ascii_value, level).first
            region = Wines::RegionTree.create(:doc => doc.to_s.to_ascii_brutal,
                                              :name_zh => name_zh,
                                              :name_en => ascii_value,
                                              :origin_name => value,
                                              :parent_id => parent,
                                              :scope => 0,
                                              :tree_left => 0,
                                              :tree_right => 0,
                                              :level => level) if region.blank?
            parent = region.id
            level = level + 1
            puts region.id
          end
        end
      end
  end

  task :init_wineries => :environment do
    require 'csv'
    require 'fileutils'
    photos_path = "lib/tasks/data/winery_photos"
    winery_path = Rails.root.join("lib", "tasks", "data", "winery.csv")
    csv  = CSV.read(winery_path)
    csv.each_with_index do |item, index|
      next if index == 0 # 跳过csv文件标题
      item.collect{|i| i.to_s.force_encoding('utf-8')} #转换数据类型
      # find region_tree_id
      region_tree = Wines::RegionTree.where("name_en = ?", item[12].to_s.to_ascii_brutal).order("level desc").first
      unless region_tree
        puts "region_tree can't be blank!"
        next
      end
      Winery.transaction do
        begin
          name_en = item[1].to_s.to_ascii_brutal
          winery = Winery.where("name_en = ?", name_en).
              first_or_create!(
              :name_en => name_en,
              :origin_name => item[1],
              :name_zh => item[2],
              :cellphone => item[3].to_s.gsub(" ", ''),
              :fax => item[4],
              :email => item[5],
              :official_site => item[6].to_s.gsub(/http:\/\//, ''),
              :address => item[7].to_s.to_ascii_brutal,
              :config => {"Facebook" => item[8], "Twitter" => item[8], "Sina" => item[9]},
              :region_tree_id => region_tree.id)
          puts winery.id
          #next unless winery.new_record? #跳过老数据
          #save_logo_and_photos
          if !item[0].blank? && Dir.exist?(Rails.root.join(photos_path, item[0]))
            if logo_path = Dir.glob(Rails.root.join(photos_path, item[0], "logo.*")).first
              winery.update_attribute("logo", open(logo_path))
            end
            Dir.glob(Rails.root.join(photos_path, item[0], "*")).each_with_index do |photo_path, index|
              next if photo_path.include?("logo")
              winery.photos.create!(
                :category => 1,
                :album_id => -1,
                :is_cover => photo_path.include?("cover") ? 1 : 0,   #设置第一张图片为封面
                :image => open(photo_path)
              )
            end
            #删除已经保存的图片
            FileUtils.rm_r(Rails.root.join(photos_path, item[0]))
          end
          #save_info_items
          unless item[13].blank?
            info_arr = item[13].split('#').collect{|i| i.to_ascii_brutal}
            info_arr.delete("") #delete ""
            info_hash = Hash[*info_arr]
            info_hash.each do |key, value|
              winery.info_items.where("title = ?", key).first_or_create!(:title => key, :description => value)
            end
          end
        rescue Exception => e
          puts e
        end

      end
    end

  end

  task :init_other_photos => :environment do
    require 'csv'
    file_path = Rails.root.join("lib/tasks/data/wines_datas.csv")
    csv  = CSV.read(file_path)
    begin
      csv.each do |item|
        item.collect{|i| i.to_s.force_encoding('utf-8')} #编码转换
        #获得图片路径
        photo_path  = Rails.root.join('lib', 'tasks','data', 'wine_photos', item[0])

        if Dir.exist? photo_path
          photos_path = []
          Dir.entries(photo_path).select{|x| x != '.' && x != '..' && x != '.DS_Store'}.each do |file_path|
            photos_path.push Rails.root.join(photo_path, file_path)
          end
        end

        next if item[9].blank? || photos_path.blank? #跳过年代为空和图片为空的
        name_en = item[1].to_s.to_ascii_brutal
        if wine_detail = Wines::Detail.joins(:wine).where("name_en = ? and year = ? ", name_en, "#{item[9]}-01-01").first
          photos_path.each do |path|
            wine_detail.photos.create(
                :category => 1,
                :album_id => -1, # no user id
                :is_cover => path.to_s.include?("cover") ? 1 : 0,
                :image => open(path)
            )
          end
          puts wine_detail.id
        end

      end
    rescue Exception => e
      puts e
    end
  end
end
