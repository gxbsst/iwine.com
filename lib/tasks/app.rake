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
      w = Wines::Style.find_or_create_by_name_en_and_name_zh(s[0], s[1])
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

    ## 导入酒和详细信息
    file_path = Rails.root.join("lib/tasks/data/wines_datas.csv")
    csv  = CSV.read(file_path)
    csv.each do |item|
      begin
        region_tree = Wines::RegionTree.where("origin_name = ? and level = ?", item[6].to_s.split('/').last, item[6].to_s.split('/').size).first
        unless region_tree
          puts "#{item[6]}  region_tree_id can't be blank!"
          next
        end
        if item[11].to_s.include?('+')
          drinkable_begin = item[11].to_s.gsub(/\+/, '')
          drinkable_end = nil
        else
          drinkable_begin = item[11].to_s.split('-').first
          drinkable_end = item[11].to_s.split('-').last
        end
        variety_arr = item[13].to_s.gsub(/\n/, '/').force_encoding('utf-8').split('/')
        next if variety_arr.size.odd?
        variety_percentage = []
        variety_name = []
        Hash[*variety_arr].each do |key, value|
          variety_name.push key
          variety_percentage.push value
        end

        wine_register = WineRegister.find_or_initialize_by_origin_name_and_vintage(item[1].to_s.force_encoding('utf-8'), item[10])
        if wine_register.new_record?
          wine_register.name_zh = item[2].to_s.force_encoding('utf-8').split('/').last
          wine_register.name_en = item[1].to_s.force_encoding('utf-8').to_ascii_brutal
          wine_register.origin_name = item[1].to_s.force_encoding 'utf-8'
          wine_register.official_site = item[3].to_s.force_encoding('utf-8').gsub(/http:\/\//, '')
          wine_register.wine_style_id =  1 #需要更改数据
          wine_register.region_tree_id = region_tree.id
          wine_register.winery_id = 1 #暂无数据
          wine_register.vintage = item[10]
          wine_register.drinkable_begin = drinkable_begin.to_i == 0 ? nil : drinkable_begin.to_i
          wine_register.drinkable_end = drinkable_end.to_i == 0 ? nil : drinkable_end.to_i
          wine_register.alcoholicity =item[12]
          wine_register.variety_percentage = variety_percentage
          wine_register.variety_name = variety_name
          wine_register.capacity = item[14]
          wine_register.status = 0
          wine_register.result = 0
          # process photo
          photo_path  = Rails.root.join('lib', 'tasks','data', 'wine_images', item[0])

          if Dir.exist? photo_path
            file_path = Rails.root.join(photo_path, Dir.entries(photo_path).select{|x| x != '.' && x != '..' && x != '.DS_Store'}.first)
            wine_register.photo_name = open(file_path)
          end
          wine_register.save
        end
       puts wine_register.id
        #wine = Wine.create(
        #  :name_en => item[1].force_encoding('utf-8').to_ascii_brutal,
        #  :origin_name => item[1].force_encoding('utf-8'),
        #  :name_zh => item[2].to_s.force_encoding('utf-8').split('/').last,
        #  :official_site => item[3].to_s.force_encoding('utf-8').gsub(/http:\/\//, ''),
        #  :wine_style_id => 1,
        #  :region_tree_id => region_tree_id,
        #  :winery_id => 1
        #)
        #
        #wine_detail = Wines::Detail.create(
        #  :drinkable_begin => drinkable_begin,
        #  :drinkable_end => drinkable_end,
        #  :alcoholicity => item[12],
        #  :capacity => item[14],
        #  :wine_id => wine.id,
        #  :year => item[9]
        #)
        #puts "#{wine.id}   #{wine_detail.id}"
      rescue Exception => e
        puts e
      end
    end
  end

  #发布酒
  desc "TODO"
  task :approve_wines => :environment do
    # 文件复制
    require 'fileutils'
    #检查图片路径
    Dir.mkdir "#{Rails.root}/public/uploads/photo" unless Dir.exist? "#{Rails.root}/public/uploads/photo"
    Dir.mkdir "#{Rails.root}/public/uploads/photo/wine" unless Dir.exist? "#{Rails.root}/public/uploads/photo/wine"

    WineRegister.where("status = ? ", 0).each do |wine_register|
      begin
        Wine.transaction do
          #添加记录
          audit_log = AuditLog.find_or_initialize_by_business_id_and_owner_type(wine_register.id, 4)
          if audit_log.new_record?
            audit_log.result = 1
            audit_log.created_by = 4
            audit_log.save!
          end
          #更新wine_register记录
          wine_register.update_attributes!(:audit_log_id => audit_log.id, :status => 1, :result => 1)
          #添加酒
          wine = Wine.find_or_initialize_by_origin_name(wine_register.origin_name)
          if wine.new_record?
            wine.name_en = wine_register.name_en
            wine.origin_name = wine_register.origin_name
            wine.name_zh = wine_register.name_zh
            wine.official_site = wine_register.official_site
            wine.wine_style_id = wine_register.wine_style_id
            wine.region_tree_id =  wine_register.region_tree_id
            wine.winery_id = wine_register.winery_id
            wine.save!
          end
          #添加酒的详细信息
          wine_detail = Wines::Detail.find_or_initialize_by_wine_id_and_year(wine.id, wine_register.vintage)
          if wine_detail.new_record?
            wine_detail.drinkable_begin = wine_register.drinkable_begin
            wine_detail.drinkable_end = wine_register.drinkable_end
            wine_detail.alcoholicity = wine_register.alcoholicity
            wine_detail.capacity = wine_register.capacity
            wine_detail.wine_style_id = wine_register.wine_style_id
            wine_detail.audit_id = audit_log.id
            wine_detail.save!
          end
          #添加酒的品种信息
          variety_percentage_arr = wine_register.variety_percentage.gsub(/\n/, '').split('-')
          wine_register.variety_name.gsub(/\n/, '').split('-').each_with_index do |value, index|
            next if value.blank?
            if wine_variety = Wines::Variety.where("origin_name = ? ", value.strip).first
               wine_variety.variety_percentages.create(:wine_detail_id => wine_detail.id, :percentage => variety_percentage_arr[index])
            end
          end
          #上传图片
          Dir.mkdir("#{Rails.root}/public/uploads/photo/wine/#{wine_detail.id}")
          FileUtils.cp_r Dir.glob("#{Rails.root}/public/uploads/wine_register/#{wine_register.id}/*"), "#{Rails.root}/public/uploads/photo/wine/#{wine_detail.id}"
          photo_path = Rails.root.join 'public', 'uploads', 'photo', 'wine', wine_detail.id.to_s, Dir.entries(Rails.root.join('public', 'uploads','photo', 'wine', wine_detail.id.to_s)).select{|x| x != '.' && x != '..' && x != '.DS_Store'}.first
          Photo.create(
              :owner_type => 2,
              :business_id => wine_detail.id,
              :category => 1,
              :album_id => 1,
              :is_cover => 1,
              :image => open(photo_path))
          puts wine.id
        end
      rescue Exception => e
        puts e
      end
    end

  end

  desc "TODO"
  task :init_region_tree => :environment do
    require 'csv'
    # TODO: “请修改下面的路径”
    file_path_directory = Rails.root.join("lib/tasks/data/region_tree/*")
    Dir.glob(file_path_directory).each do |csv_file|
      puts "=============== begin #{csv_file} ====================="
      csv = CSV.read(csv_file)
      csv.each do |item|
        doc = item.pop if item.size.odd?
        item_to_hash = Hash[*item]
        last_value = item_to_hash.values.last.to_s.force_encoding('utf-8')
        parent = 0
        level = 1
        item_to_hash.each do |key, value|
          #binding.pry
          unless value.blank?
            value = "#{value.force_encoding('utf-8')}"
            ascii_value = value.force_encoding("utf-8").to_ascii_brutal
            name_zh = key.blank? ? ascii_value : key
            # TODO:
            # 如果处理以下
            # 1. 法国,France,波尔多,Bordeaux,梅多克,Médoc,梅多克,Médoc
            # 2. 添加一个字段， 保存原生文字，如:RhÃ´ne Valley, name_en 保存 RhA´ne Valley
            # 转换方法: "Moulis/ Moulis-en-MÃ©doc".to_ascii_brutal => https://github.com/tomash/ascii_tic
            region = Wines::RegionTree.where("name_en = ? and level = ? ", value, level).first
            region = Wines::RegionTree.create(:doc => value == last_value ? doc : nil,:name_zh => name_zh, :name_en => ascii_value, :origin_name => value, :parent_id => parent, :scope => 0, :tree_left => 0, :tree_right => 0, :level => level) if region.blank?
            parent = region.id
            level = level + 1
          end
        end
      end
    end
  end

end

